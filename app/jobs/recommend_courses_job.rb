class RecommendCoursesJob < ApplicationJob
  queue_as :ai_analysis
  
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  def perform(application_id)
    application = Application.find(application_id)
    
    Rails.logger.info(
      message: "Starting course recommendations",
      application_id: application_id,
      user_id: application.user_id
    )
    
    # Ensure application has been analyzed
    unless application.analyzed?
      Rails.logger.warn(
        message: "Application not analyzed, skipping course recommendations",
        application_id: application_id
      )
      return
    end
    
    # Initialize the course recommendation service
    recommendation_service = CourseRecommendationService.new(application)
    
    # Get personalized course recommendations
    result = recommendation_service.get_personalized_recommendations
    
    if result[:success]
      courses_count = result[:courses]&.count || 0
      
      Rails.logger.info(
        message: "Course recommendations completed successfully",
        application_id: application_id,
        courses_found: courses_count,
        has_personalization: result[:personalization_rationale].present?
      )
      
      # Store recommendations for caching (optional)
      Rails.cache.write(
        "course_recommendations_#{application_id}",
        result,
        expires_in: 24.hours
      )
      
      # Notify user if desired (future enhancement)
      # NotifyUserJob.perform_later(application.user_id, :course_recommendations_ready)
      
    else
      Rails.logger.error(
        message: "Course recommendation failed",
        application_id: application_id,
        error: result[:error]
      )
      
      raise StandardError, "Course recommendation failed: #{result[:error]}"
    end
    
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error(
      message: "Application not found for course recommendations",
      application_id: application_id
    )
    raise
    
  rescue => e
    Rails.logger.error(
      message: "Course recommendation job failed",
      application_id: application_id,
      error: e.message,
      backtrace: e.backtrace&.first(10)
    )
    raise
  end
end