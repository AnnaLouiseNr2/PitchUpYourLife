class CreateClJob < ApplicationJob
  queue_as :default

  def perform(application_id, prompt)
    application = Application.find(application_id)
    service = AiContentService.new(application)
    
    result = service.generate_cover_letter(prompt)
    
    if result[:success]
      application.update!(cl_message: result[:content], cl_status: "done")
    else
      application.update!(cl_status: "error: #{result[:error]}")
      raise StandardError, result[:error]
    end
  end
end
