class CreateClJob < ApplicationJob
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

    response = chat.ask("Help me generate the paragraphs with the job description here: #{application.job_d}, my resume is here: #{cv_file}")

    application.update!(coverletter_message: response.content, coverletter_status: "done")
  rescue => e
    Rails.logger.error "CreateClJob failed for application #{application_id}: #{e.message}"
    application.update!(coverletter_status: "error: #{e.message}")
    raise
  end
end
