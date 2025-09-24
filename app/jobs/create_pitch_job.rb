class CreatePitchJob < ApplicationJob
  queue_as :default

  def perform(application_id, prompt)
    application = Application.find(application_id)

    begin
      cv_file = CvTextExtractor.call(application)
    rescue => e
      Rails.logger.error "Error extracting CV for application #{application.id}: #{e.message}"
      cv_file = ""  # Continue without CV content
    end

    chat = RubyLLM.chat
    chat.with_instructions(prompt)

    response = chat.ask("Help me generate the pitch with the job description here: #{application.job_d}, my resume is here: #{cv_file}")

    application.update!(video_message: response.content, video_status: "done")
  rescue => e
    Rails.logger.error "CreatePitchJob failed for application #{application_id}: #{e.message}"
    application.update!(video_status: "error: #{e.message}")
    raise
  end
end
