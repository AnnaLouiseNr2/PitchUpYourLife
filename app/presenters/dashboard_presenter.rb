# Presenter for Application Dashboard view to encapsulate user stats and application display logic
class DashboardPresenter
  def initialize(user, applications, view_context = nil)
    @user = user
    @applications = applications
    @view_context = view_context
  end

  # Format user's display name from email
  def user_display_name
    return 'User' unless @user&.email.present?
    
    @user.email.split('@').first.split('.').map(&:capitalize).join(' ')
  end

  # Format user's member since date
  def member_since_date
    return 'N/A' unless @user&.created_at.present?
    
    @user.created_at.strftime('%B %Y')
  end

  # Get total application count
  def total_applications_count
    @applications&.count || 0
  end

  # Get applications created this week count
  def applications_this_week_count
    return 0 unless @applications.present?
    
    @applications.select { |app| app.created_at >= 1.week.ago }.count
  end

  # Get recent applications (limited for display)
  def recent_applications(limit = 10)
    return [] unless @applications.present?
    
    @applications.reverse.first(limit).map { |app| ApplicationPresenter.new(app, @view_context) }
  end

  # Check if user has any applications
  def has_applications?
    total_applications_count > 0
  end

  # Get application stats for display
  def application_stats
    return [] unless @applications.present?

    completed = @applications.count { |app| app.cl_status == 'done' && app.video_status == 'done' }
    in_progress = @applications.count { |app| ['processing', 'pending'].include?(app.cl_status) || ['processing', 'pending'].include?(app.video_status) }
    
    [
      { label: 'Total Applications', count: total_applications_count, badge_class: 'bg-light text-dark' },
      { label: 'Completed', count: completed, badge_class: 'bg-success text-white' },
      { label: 'In Progress', count: in_progress, badge_class: 'bg-warning text-dark' },
      { label: 'This Week', count: applications_this_week_count, badge_class: 'bg-primary text-white' }
    ]
  end

  # Get user status text
  def user_status
    return 'Inactive' unless @user.present?
    
    'Active'
  end

  # Check if user is new (created within last 30 days)
  def new_user?
    return false unless @user&.created_at.present?
    
    @user.created_at >= 30.days.ago
  end

  # Get welcome message based on user activity
  def welcome_message
    if new_user?
      "Welcome to PitchUpYourLife! Start by creating your first application."
    elsif has_applications?
      "Welcome back! You have #{total_applications_count} application#{'s' if total_applications_count != 1}."
    else
      "Ready to land your dream job? Create your first application to get started."
    end
  end

  # Search applications by company name or job title
  def search_applications(query)
    return recent_applications if query.blank?
    
    filtered = @applications.select do |app|
      app.name&.downcase&.include?(query.downcase) ||
      app.title&.downcase&.include?(query.downcase) ||
      app.job_d&.downcase&.include?(query.downcase)
    end
    
    filtered.reverse.map { |app| ApplicationPresenter.new(app, @view_context) }
  end
end