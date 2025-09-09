class GenerateMlPredictionsJob < ApplicationJob
  queue_as :high
  
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  def perform(application_id, user_id)
    application = Application.find(application_id)
    user = User.find(user_id)
    
    Rails.logger.info(
      message: "Starting ML predictions generation",
      application_id: application_id,
      user_id: user_id
    )
    
    # Initialize ML service
    ml_service = MlPredictionService.new(user, application)
    
    # Generate comprehensive predictions
    result = ml_service.generate_comprehensive_predictions
    
    if result[:success]
      predictions_count = result[:predictions].values.count { |p| p[:success] }
      
      Rails.logger.info(
        message: "ML predictions generated successfully",
        application_id: application_id,
        user_id: user_id,
        predictions_generated: predictions_count
      )
      
      # Optional: Send notification to user
      # NotifyUserJob.perform_later(user_id, :ml_predictions_ready, application_id)
      
    else
      failed_predictions = result[:predictions].select { |_, p| !p[:success] }
      error_messages = failed_predictions.values.map { |p| p[:error] }.compact
      
      Rails.logger.error(
        message: "ML predictions generation failed",
        application_id: application_id,
        user_id: user_id,
        failed_predictions: failed_predictions.keys,
        errors: error_messages
      )
      
      raise StandardError, "Predictions failed: #{error_messages.join(', ')}"
    end
    
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error(
      message: "Record not found for ML predictions",
      application_id: application_id,
      user_id: user_id,
      error: e.message
    )
    raise
    
  rescue => e
    Rails.logger.error(
      message: "ML predictions job failed",
      application_id: application_id,
      user_id: user_id,
      error: e.message,
      backtrace: e.backtrace&.first(10)
    )
    raise
  end
end