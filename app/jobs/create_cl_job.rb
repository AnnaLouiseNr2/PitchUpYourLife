class CreateClJob < ApplicationJob
  queue_as :default

  def perform(application_id, prompt)
    application = Application.find(application_id)
    ai_service = AiContentService.new(application)
    
    result = ai_service.generate_cover_letter(prompt)
    
    if result[:success]
      application.update!(coverletter_message: result[:content], coverletter_status: "completed")
    else
      application.update!(coverletter_status: "failed")
      raise StandardError, result[:error]
    end
  end
end
