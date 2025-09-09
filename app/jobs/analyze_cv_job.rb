class AnalyzeCvJob < ApplicationJob
  queue_as :ai_analysis
  
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  def perform(application_id)
    application = Application.find(application_id)
    
    Rails.logger.info(
      message: "Starting CV analysis",
      application_id: application_id,
      user_id: application.user_id
    )
    
    # Initialize the analysis service
    analysis_service = ProfileAnalysisService.new(application)
    
    # Perform CV analysis
    cv_result = analysis_service.analyze_cv
    skills_result = analysis_service.analyze_skills_gap
    
    # Update application with results
    if cv_result[:success] && skills_result[:success]
      application.update!(
        cv_analysis: cv_result[:analysis],
        skills_gap_analysis: skills_result[:skills_gap],
        analyzed_at: Time.current,
        analysis_version: '1.0'
      )
      
      Rails.logger.info(
        message: "CV analysis completed successfully",
        application_id: application_id,
        matching_score: cv_result[:analysis]&.dig('matching_score'),
        skills_analyzed: skills_result[:skills_gap].present?
      )
      
      # Queue course recommendation job
      RecommendCoursesJob.perform_later(application_id)
      
    else
      error_messages = [cv_result[:error], skills_result[:error]].compact
      
      Rails.logger.error(
        message: "CV analysis failed",
        application_id: application_id,
        errors: error_messages
      )
      
      raise StandardError, "Analysis failed: #{error_messages.join(', ')}"
    end
    
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error(
      message: "Application not found for CV analysis",
      application_id: application_id
    )
    raise
    
  rescue => e
    Rails.logger.error(
      message: "CV analysis job failed",
      application_id: application_id,
      error: e.message,
      backtrace: e.backtrace&.first(10)
    )
    raise
  end
end