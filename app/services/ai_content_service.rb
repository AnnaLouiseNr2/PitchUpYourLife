require "ruby_llm"

# Service class to centralize all AI content generation functionality
# This replaces direct RubyLLM.chat calls scattered throughout the codebase
class AiContentService
  def initialize(application)
    @application = application
  end

  # Generate cover letter content using the provided prompt and application data
  def generate_cover_letter(prompt)
    ActiveSupport::Notifications.instrument(
      'ai_content_generation.application',
      service: 'AiContentService',
      method: 'generate_cover_letter',
      application_id: @application.id
    ) do |payload|
      
      cv_file = extract_cv_text
      chat = RubyLLM.chat
      chat.with_instructions(prompt)
      
      response = chat.ask(
        "Help me generate the paragraphs with the job description here: #{@application.job_d}, " \
        "my resume is here: #{cv_file}, please refer to my resume when generating the contents."
      )
      
      payload[:success] = true
      {
        success: true,
        content: response.content,
        error: nil
      }
    end
  rescue => e
    Rails.logger.error(
      message: "AI content generation failed",
      service: 'AiContentService',
      method: 'generate_cover_letter',
      application_id: @application.id,
      error: e.message,
      backtrace: e.backtrace&.first(5)
    )
    
    {
      success: false,
      content: nil,
      error: e.message
    }
  end

  # Generate video pitch script using the provided prompt and application data
  def generate_pitch_script(prompt)
    ActiveSupport::Notifications.instrument(
      'ai_content_generation.application',
      service: 'AiContentService',
      method: 'generate_pitch_script',
      application_id: @application.id
    ) do |payload|
      
      cv_file = extract_cv_text
      chat = RubyLLM.chat
      chat.with_instructions(prompt)
      
      response = chat.ask(
        "Help me generate the pitch with the job description here: #{@application.job_d}, " \
        "my resume is here: #{cv_file}, please refer to my resume when generating the contents."
      )
      
      payload[:success] = true
      {
        success: true,
        content: response.content,
        error: nil
      }
    end
  rescue => e
    Rails.logger.error(
      message: "AI content generation failed",
      service: 'AiContentService',
      method: 'generate_pitch_script',
      application_id: @application.id,
      error: e.message,
      backtrace: e.backtrace&.first(5)
    )
    
    {
      success: false,
      content: nil,
      error: e.message
    }
  end

  # Extract company name from job description
  def extract_company_name
    prompt = <<~PROMPT
      From the job description I give to you, I want you to extract the company name that I'm applying to. RULES: The response
      should only contain the name of the company, no talking or chatting, I want it to be very straight forward. No response
      of confirming the creation, no message delivered to me, just the company name, plain texts.
    PROMPT

    chat = RubyLLM.chat
    chat.with_instructions(prompt)
    response = chat.ask("Help me generate the company name with the job description here: #{@application.job_d}")
    
    {
      success: true,
      content: response.content,
      error: nil
    }
  rescue => e
    {
      success: false,
      content: nil,
      error: e.message
    }
  end

  # Extract job title from job description
  def extract_job_title
    prompt = <<~PROMPT
      From the job description I give to you, I want you to extract the role title that I'm applying to. RULES: The response
      should only contain the name of the role title, no talking or chatting, I want it to be very straight forward. No response
      of confirming the creation, no message delivered to me, just the role title, plain texts.
    PROMPT

    chat = RubyLLM.chat
    chat.with_instructions(prompt)
    response = chat.ask("Help me generate the role title with the job description here: #{@application.job_d}")
    
    {
      success: true,
      content: response.content,
      error: nil
    }
  rescue => e
    {
      success: false,
      content: nil,
      error: e.message
    }
  end

  private

  def extract_cv_text
    CvTextExtractor.call(@application)
  end
end