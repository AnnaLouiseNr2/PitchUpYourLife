class CreateClJob < ApplicationJob
  queue_as :default

  def perform(application_id, prompt)
    application = Application.find(application_id)

    cv_file   = CvTextExtractor.call(application)
    chat      = RubyLLM.chat
    chat.with_instructions(prompt)

    response = chat.ask("Help me generate the paragraphs with the job description here: #{application.job_d}, my resume is here: #{cv_file}")

    application.update!(cl_message: response.content, cl_status: "done")
  rescue StandardError => e
    application.update!(cl_status: "error: #{e.message}")
    raise
  end
end
