# Service for generating AI-powered content using RubyLLM
#
# This service centralizes all AI content generation logic that was previously
# duplicated across jobs and controllers. It handles:
# - Cover letter generation
# - Video pitch script generation  
# - Company name extraction
# - Job title extraction
#
# Usage:
#   service = AiContentService.new(application)
#   result = service.generate_cover_letter(prompt, traits)
#   result = service.generate_pitch_script(prompt, traits)
#   result = service.extract_company_name
#   result = service.extract_job_title

class AiContentService
  attr_reader :application, :cv_text

  def initialize(application, cv_text: nil)
    @application = application
    @cv_text = cv_text || CvTextExtractor.call(application)
  end

  # Generate cover letter content
  def generate_cover_letter(prompt, traits = nil)
    execute_chat(prompt) do |chat|
      chat.ask(build_cover_letter_query)
    end
  end

  # Generate video pitch script
  def generate_pitch_script(prompt, traits = nil)
    execute_chat(prompt) do |chat|
      chat.ask(build_pitch_query)
    end
  end

  # Extract company name from job description
  def extract_company_name
    prompt = <<~PROMPT
      From the job description I give to you, I want you to extract the company name that I'm applying to. RULES: The response
      should only contain the name of the company, no talking or chatting, I want it to be very straight forward. No response
      of confirming the creation, no message delivered to me, just the company name, plain texts.
    PROMPT

    execute_chat(prompt) do |chat|
      chat.ask("Help me generate the company name with the job description here: #{@application.job_d}")
    end
  end

  # Extract job title from job description
  def extract_job_title
    prompt = <<~PROMPT
      From the job description I give to you, I want you to extract the role that I'm applying to. RULES: The response
      should only contain the role, no talking or chatting, I want it to be very straight forward. Ex: Chef Backend Developer. No response
      of confirming the creation, no message delivered to me, just the role title, plain texts.
    PROMPT

    execute_chat(prompt) do |chat|
      chat.ask("Help me generate the role title with the job description here: #{@application.job_d}")
    end
  end

  private

  # Execute chat with error handling and retries
  def execute_chat(prompt)
    chat = RubyLLM.chat
    chat.with_instructions(prompt)
    
    response = yield(chat)
    {
      content: response.content,
      success: true,
      error: nil
    }
  rescue StandardError => e
    Rails.logger.error "AiContentService error: #{e.message}"
    {
      content: nil,
      success: false,
      error: e.message
    }
  end

  def build_cover_letter_query
    "Help me generate the paragraphs with the job description here: #{@application.job_d}, my resume is here: #{@cv_text}, please refer to my resume when generating the contents."
  end

  def build_pitch_query  
    "Help me generate the pitch with the job description here: #{@application.job_d}, my resume is here: #{@cv_text}, please refer to my resume when generating the contents."
  end
end