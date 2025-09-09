require "ruby_llm"

# Service class for CV analysis and profile optimization feedback
# Provides ATS keyword optimization and content quality analysis
class ProfileAnalysisService
  def initialize(application)
    @application = application
  end

  # Analyze CV for ATS optimization and content quality
  def analyze_cv
    ActiveSupport::Notifications.instrument(
      'ai_content_generation.application',
      service: 'ProfileAnalysisService',
      method: 'analyze_cv',
      application_id: @application.id
    ) do |payload|
      
      cv_text = extract_cv_text
      job_description = @application.job_d
      
      analysis_prompt = build_analysis_prompt
      chat = RubyLLM.chat
      chat.with_instructions(analysis_prompt)
      
      response = chat.ask(
        "Please analyze this CV against the job description. " \
        "CV: #{cv_text} " \
        "Job Description: #{job_description}"
      )
      
      parsed_analysis = parse_analysis_response(response.content)
      
      payload[:success] = true
      {
        success: true,
        analysis: parsed_analysis,
        error: nil
      }
    end
  rescue => e
    Rails.logger.error(
      message: "CV analysis failed",
      service: 'ProfileAnalysisService',
      method: 'analyze_cv',
      application_id: @application.id,
      error: e.message,
      backtrace: e.backtrace&.first(5)
    )
    
    {
      success: false,
      analysis: nil,
      error: e.message
    }
  end

  # Generate skills gap analysis for course recommendations
  def analyze_skills_gap
    ActiveSupport::Notifications.instrument(
      'ai_content_generation.application',
      service: 'ProfileAnalysisService',
      method: 'analyze_skills_gap',
      application_id: @application.id
    ) do |payload|
      
      cv_text = extract_cv_text
      job_description = @application.job_d
      
      skills_prompt = build_skills_analysis_prompt
      chat = RubyLLM.chat
      chat.with_instructions(skills_prompt)
      
      response = chat.ask(
        "Analyze skills gap between CV and job requirements. " \
        "CV: #{cv_text} " \
        "Job Description: #{job_description}"
      )
      
      skills_analysis = parse_skills_response(response.content)
      
      payload[:success] = true
      {
        success: true,
        skills_gap: skills_analysis,
        error: nil
      }
    end
  rescue => e
    Rails.logger.error(
      message: "Skills gap analysis failed",
      service: 'ProfileAnalysisService',
      method: 'analyze_skills_gap',
      application_id: @application.id,
      error: e.message,
      backtrace: e.backtrace&.first(5)
    )
    
    {
      success: false,
      skills_gap: nil,
      error: e.message
    }
  end

  private

  def extract_cv_text
    CvTextExtractor.call(@application)
  end

  def build_analysis_prompt
    <<~PROMPT
      You are an expert ATS (Applicant Tracking System) and HR consultant. Analyze the provided CV against the job description and provide structured feedback in JSON format.

      Your analysis should include:
      1. ATS Keywords - missing keywords from job description that should be included
      2. Content Quality - areas for improvement in presentation and structure
      3. Matching Score - overall compatibility percentage
      4. Specific Suggestions - actionable improvements

      Return your analysis in this exact JSON structure:
      {
        "ats_keywords": {
          "missing": ["keyword1", "keyword2"],
          "present": ["keyword3", "keyword4"],
          "suggestions": ["Add 'keyword1' to skills section", "Include 'keyword2' in experience"]
        },
        "content_quality": {
          "score": 75,
          "strengths": ["Clear formatting", "Relevant experience"],
          "improvements": ["Add quantified achievements", "Improve summary section"]
        },
        "matching_score": 78,
        "specific_suggestions": [
          {
            "section": "Summary",
            "current": "Current text",
            "suggested": "Improved text",
            "reason": "Why this improvement helps"
          }
        ]
      }

      Be specific, actionable, and focus on improvements that will help pass ATS systems and impress recruiters.
    PROMPT
  end

  def build_skills_analysis_prompt
    <<~PROMPT
      You are a career development expert. Analyze the skills gap between the candidate's CV and job requirements.

      Identify:
      1. Missing technical skills
      2. Missing soft skills  
      3. Skills to strengthen
      4. Learning priorities

      Return analysis in this JSON structure:
      {
        "technical_skills": {
          "missing": ["React", "Python", "AWS"],
          "weak": ["JavaScript", "SQL"],
          "strong": ["HTML", "CSS"]
        },
        "soft_skills": {
          "missing": ["Leadership", "Project Management"],
          "weak": ["Communication"],
          "strong": ["Problem Solving"]
        },
        "learning_priorities": [
          {
            "skill": "React",
            "importance": "high",
            "reason": "Required for 80% of job responsibilities"
          }
        ],
        "recommended_courses": [
          {
            "category": "Frontend Development",
            "skills": ["React", "TypeScript"]
          }
        ]
      }
    PROMPT
  end

  def parse_analysis_response(content)
    JSON.parse(content)
  rescue JSON::ParserError => e
    Rails.logger.warn(
      message: "Failed to parse CV analysis JSON response",
      content: content,
      error: e.message
    )
    
    # Return fallback structure
    {
      "ats_keywords" => {
        "missing" => [],
        "present" => [],
        "suggestions" => ["Unable to parse AI response"]
      },
      "content_quality" => {
        "score" => 0,
        "strengths" => [],
        "improvements" => ["Unable to analyze content"]
      },
      "matching_score" => 0,
      "specific_suggestions" => []
    }
  end

  def parse_skills_response(content)
    JSON.parse(content)
  rescue JSON::ParserError => e
    Rails.logger.warn(
      message: "Failed to parse skills analysis JSON response",
      content: content,
      error: e.message
    )
    
    # Return fallback structure
    {
      "technical_skills" => {
        "missing" => [],
        "weak" => [],
        "strong" => []
      },
      "soft_skills" => {
        "missing" => [],
        "weak" => [],
        "strong" => []
      },
      "learning_priorities" => [],
      "recommended_courses" => []
    }
  end
end