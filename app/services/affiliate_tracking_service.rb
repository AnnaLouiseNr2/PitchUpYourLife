# Service class for affiliate link click tracking and analytics
# Handles click recording, conversion tracking, and revenue analytics
class AffiliateTrackingService
  def initialize(user, course_id = nil)
    @user = user
    @course_id = course_id
  end

  # Record a click on an affiliate link
  def track_click(affiliate_url, source_context = {})
    click = Click.create!(
      user: @user,
      course_id: @course_id,
      clicked_at: Time.current,
      ip_address: source_context[:ip_address],
      user_agent: source_context[:user_agent],
      referrer: source_context[:referrer],
      utm_source: source_context[:utm_source],
      utm_medium: source_context[:utm_medium],
      utm_campaign: source_context[:utm_campaign],
      application_id: source_context[:application_id]
    )

    Rails.logger.info(
      message: "Affiliate click tracked",
      click_id: click.id,
      user_id: @user.id,
      course_id: @course_id,
      affiliate_url: affiliate_url
    )

    {
      success: true,
      click_id: click.id,
      tracked_url: build_tracking_url(affiliate_url, click.id),
      error: nil
    }
  rescue => e
    Rails.logger.error(
      message: "Failed to track affiliate click",
      user_id: @user.id,
      course_id: @course_id,
      error: e.message,
      backtrace: e.backtrace&.first(5)
    )

    {
      success: false,
      click_id: nil,
      tracked_url: affiliate_url, # Fallback to original URL
      error: e.message
    }
  end

  # Generate analytics for affiliate performance
  def generate_analytics(date_range = 30.days.ago..Time.current)
    clicks = Click.includes(:course, :user, :application)
                  .where(clicked_at: date_range)

    total_clicks = clicks.count
    unique_users = clicks.distinct.count(:user_id)
    unique_courses = clicks.distinct.count(:course_id)
    
    # Click breakdown by course
    clicks_by_course = clicks.joins(:course)
                           .group('courses.title')
                           .count
    
    # Click breakdown by time period
    clicks_by_day = clicks.group_by_day(:clicked_at).count
    
    # User engagement metrics
    user_click_distribution = clicks.group(:user_id).count.values
    avg_clicks_per_user = user_click_distribution.sum.to_f / user_click_distribution.count
    
    # Course performance metrics
    course_performance = clicks.joins(:course)
                              .group('courses.id', 'courses.title', 'courses.provider', 'courses.price')
                              .group('courses.affiliate_commission_rate')
                              .count
                              .map do |(course_id, title, provider, price, commission_rate), click_count|
      potential_revenue = calculate_potential_revenue(price, commission_rate, click_count)
      
      {
        course_id: course_id,
        title: title,
        provider: provider,
        price: price,
        commission_rate: commission_rate,
        clicks: click_count,
        potential_revenue: potential_revenue
      }
    end.sort_by { |c| -c[:clicks] }

    {
      summary: {
        total_clicks: total_clicks,
        unique_users: unique_users,
        unique_courses: unique_courses,
        avg_clicks_per_user: avg_clicks_per_user.round(2),
        date_range: {
          start: date_range.begin.strftime('%Y-%m-%d'),
          end: date_range.end.strftime('%Y-%m-%d')
        }
      },
      clicks_by_course: clicks_by_course,
      clicks_by_day: clicks_by_day,
      course_performance: course_performance,
      top_performing_courses: course_performance.first(5),
      total_potential_revenue: course_performance.sum { |c| c[:potential_revenue] }
    }
  end

  # Get user's click history
  def user_click_history(limit = 50)
    clicks = Click.includes(:course, :application)
                  .where(user: @user)
                  .order(clicked_at: :desc)
                  .limit(limit)

    clicks.map do |click|
      {
        id: click.id,
        clicked_at: click.clicked_at,
        course: click.course&.title,
        provider: click.course&.provider,
        application: {
          id: click.application&.id,
          company: click.application&.company_name,
          job_title: click.application&.job_title
        },
        utm_source: click.utm_source,
        utm_campaign: click.utm_campaign
      }
    end
  end

  # Track conversion (when user actually enrolls in a course)
  def track_conversion(click_id, conversion_value = nil)
    click = Click.find(click_id)
    
    click.update!(
      converted: true,
      converted_at: Time.current,
      conversion_value: conversion_value
    )

    Rails.logger.info(
      message: "Affiliate conversion tracked",
      click_id: click_id,
      user_id: @user.id,
      course_id: click.course_id,
      conversion_value: conversion_value
    )

    {
      success: true,
      click_id: click_id,
      conversion_tracked: true
    }
  rescue ActiveRecord::RecordNotFound
    {
      success: false,
      error: "Click not found"
    }
  rescue => e
    Rails.logger.error(
      message: "Failed to track conversion",
      click_id: click_id,
      error: e.message
    )

    {
      success: false,
      error: e.message
    }
  end

  # Get conversion analytics
  def conversion_analytics(date_range = 30.days.ago..Time.current)
    clicks = Click.where(clicked_at: date_range)
    conversions = clicks.where(converted: true)

    total_clicks = clicks.count
    total_conversions = conversions.count
    conversion_rate = total_clicks > 0 ? (total_conversions.to_f / total_clicks * 100).round(2) : 0
    
    total_revenue = conversions.where.not(conversion_value: nil)
                              .sum(:conversion_value) || 0

    avg_conversion_value = total_conversions > 0 ? 
      (total_revenue.to_f / total_conversions).round(2) : 0

    # Conversion by course
    conversions_by_course = conversions.joins(:course)
                                      .group('courses.title')
                                      .count

    {
      summary: {
        total_clicks: total_clicks,
        total_conversions: total_conversions,
        conversion_rate: conversion_rate,
        total_revenue: total_revenue,
        avg_conversion_value: avg_conversion_value
      },
      conversions_by_course: conversions_by_course,
      top_converting_courses: conversions_by_course.sort_by { |_, count| -count }.first(5).to_h
    }
  end

  private

  def build_tracking_url(affiliate_url, click_id)
    # Add click tracking parameter to affiliate URL
    separator = affiliate_url.include?('?') ? '&' : '?'
    "#{affiliate_url}#{separator}cc_click_id=#{click_id}"
  end

  def calculate_potential_revenue(price, commission_rate, click_count)
    return 0 if price.nil? || commission_rate.nil?
    
    # Assume average conversion rate of 2% for potential revenue calculation
    estimated_conversions = click_count * 0.02
    commission_per_sale = price * (commission_rate / 100.0)
    
    (estimated_conversions * commission_per_sale).round(2)
  end
end