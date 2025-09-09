class CreatePitchJob < ApplicationJob
  queue_as :default

  def perform(application_id, prompt)
    application = Application.find(application_id)
    ai_service = AiContentService.new(application)
    
    result = ai_service.generate_pitch_script(prompt)
    
    if result[:success]
      application.update!(video_message: result[:content], video_status: "done")
    else
      application.update!(video_status: "error: #{result[:error]}")
      raise StandardError, result[:error]
    end
  end
end
