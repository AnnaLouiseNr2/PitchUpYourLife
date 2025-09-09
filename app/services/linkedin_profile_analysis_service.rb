# LinkedIn PDF Profile Analysis Service
# Phase 3: PDF-based LinkedIn profile analysis (no API required)

class LinkedinProfileAnalysisService
  def initialize(user)
    @user = user
  end

  # Analyze uploaded LinkedIn profile PDF
  def analyze_profile_pdf(pdf_file)
    ActiveSupport::Notifications.instrument(
      'linkedin_profile_analysis.user',
      service: 'LinkedinProfileAnalysisService',
      method: 'analyze_profile_pdf',
      user_id: @user.id
    ) do |payload|
      
      # Extract text from LinkedIn PDF
      profile_text = extract_pdf_text(pdf_file)
      
      # AI-powered analysis of LinkedIn profile
      analysis_result = analyze_with_ai(profile_text)
      
      payload[:success] = analysis_result[:success]
      payload[:profile_sections] = analysis_result[:analysis]&.keys&.count || 0
      
      analysis_result
    end
  rescue => e
    Rails.logger.error(
      message: "LinkedIn profile analysis failed",
      service: 'LinkedinProfileAnalysisService',
      method: 'analyze_profile_pdf',
      user_id: @user.id,
      error: e.message,
      backtrace: e.backtrace&.first(5)
    )
    
    {
      success: false,
      analysis: nil,
      error: e.message
    }
  end

  # Get profile improvement recommendations
  def get_profile_recommendations(profile_analysis)
    return { success: false, error: "No analysis data provided" } unless profile_analysis.present?

    recommendations_prompt = build_recommendations_prompt(profile_analysis)
    
    chat = RubyLLM.chat
    chat.with_instructions(recommendations_prompt)
    
    response = chat.ask("Provide specific recommendations to improve this LinkedIn profile for better job opportunities.")
    
    parsed_recommendations = parse_recommendations_response(response.content)
    
    {
      success: true,
      recommendations: parsed_recommendations,
      error: nil
    }
  rescue => e
    Rails.logger.error(
      message: "LinkedIn recommendations generation failed",
      user_id: @user.id,
      error: e.message
    )
    
    {
      success: false,
      recommendations: nil,
      error: e.message
    }
  end

  # Score profile completeness and quality
  def calculate_profile_score(profile_analysis)
    return 0 unless profile_analysis.present?

    score = 0
    max_score = 100

    # Profile completeness scoring
    score += 15 if profile_analysis.dig('basic_info', 'headline').present?
    score += 10 if profile_analysis.dig('basic_info', 'summary').present?
    score += 15 if profile_analysis.dig('experience')&.any?
    score += 10 if profile_analysis.dig('education')&.any?
    score += 10 if profile_analysis.dig('skills')&.any?
    score += 5 if profile_analysis.dig('certifications')&.any?
    score += 5 if profile_analysis.dig('languages')&.any?

    # Quality scoring based on content depth
    summary_length = profile_analysis.dig('basic_info', 'summary')&.length || 0
    score += 10 if summary_length > 200 # Good summary length

    experience_count = profile_analysis.dig('experience')&.count || 0
    score += 10 if experience_count >= 3 # Sufficient experience entries

    skills_count = profile_analysis.dig('skills')&.count || 0
    score += 10 if skills_count >= 10 # Good skills variety

    # Cap at max score
    [score, max_score].min
  end

  private

  def extract_pdf_text(pdf_file)
    # Use existing CvTextExtractor logic adapted for LinkedIn PDFs
    if pdf_file.is_a?(ActionDispatch::Http::UploadedFile) || pdf_file.is_a?(Tempfile)
      reader = PDF::Reader.new(pdf_file)
      text = reader.pages.map(&:text).join("\n")
    else
      # Handle Active Storage attachment
      pdf_file.download do |file|
        reader = PDF::Reader.new(file)
        text = reader.pages.map(&:text).join("\n")
      end
    end
    
    text.strip
  rescue => e
    Rails.logger.error("Failed to extract text from LinkedIn PDF: #{e.message}")
    ""
  end

  def analyze_with_ai(profile_text)
    analysis_prompt = build_analysis_prompt
    
    chat = RubyLLM.chat
    chat.with_instructions(analysis_prompt)
    
    response = chat.ask("Analyze this LinkedIn profile: #{profile_text}")
    
    analysis = parse_analysis_response(response.content)
    
    {
      success: true,
      analysis: analysis,
      raw_text: profile_text,
      error: nil
    }
  end

  def build_analysis_prompt
    <<~PROMPT
      You are a LinkedIn profile optimization expert and career coach. Analyze the provided LinkedIn profile text and extract structured information.

      Please provide your analysis in this exact JSON structure:
      {
        "basic_info": {
          "name": "Full Name",
          "headline": "Professional Headline",
          "location": "City, Country", 
          "summary": "Profile summary/about section"
        },
        "experience": [
          {
            "title": "Job Title",
            "company": "Company Name",
            "duration": "Duration (e.g., 2 years 3 months)",
            "description": "Job description",
            "key_achievements": ["Achievement 1", "Achievement 2"]
          }
        ],
        "education": [
          {
            "degree": "Degree Name",
            "institution": "University/School Name",
            "year": "Year or duration"
          }
        ],
        "skills": ["Skill 1", "Skill 2", "Skill 3"],
        "certifications": [
          {
            "name": "Certification Name",
            "issuer": "Issuing Organization",
            "date": "Date issued"
          }
        ],
        "languages": ["Language 1", "Language 2"],
        "analysis": {
          "profile_strength": "Brief assessment of profile strength",
          "missing_elements": ["Missing element 1", "Missing element 2"],
          "industry_focus": "Primary industry/field",
          "experience_level": "Junior/Mid/Senior/Executive",
          "key_skills_gap": ["Skill gaps for target roles"]
        }
      }

      Focus on extracting accurate information from the profile text. If information is not available, use null or empty arrays.
      Provide professional, constructive analysis in the analysis section.
    PROMPT
  end

  def parse_analysis_response(content)
    JSON.parse(content)
  rescue JSON::ParserError => e
    Rails.logger.warn(
      message: "Failed to parse LinkedIn profile analysis JSON",
      content: content,
      error: e.message
    )
    
    # Return fallback structure
    {
      "basic_info" => {
        "name" => nil,
        "headline" => nil,
        "location" => nil,
        "summary" => nil
      },
      "experience" => [],
      "education" => [],
      "skills" => [],
      "certifications" => [],
      "languages" => [],
      "analysis" => {
        "profile_strength" => "Unable to analyze - parsing error",
        "missing_elements" => ["Complete profile analysis unavailable"],
        "industry_focus" => "Unknown",
        "experience_level" => "Unknown",
        "key_skills_gap" => []
      }
    }
  end

  def build_recommendations_prompt(profile_analysis)
    <<~PROMPT
      You are a LinkedIn profile optimization expert. Based on the profile analysis provided, give specific, actionable recommendations to improve this LinkedIn profile for better job opportunities.

      Focus on:
      1. Profile completeness and missing sections
      2. Keyword optimization for better discoverability
      3. Content quality improvements
      4. Industry-specific best practices
      5. Professional branding enhancements

      Provide recommendations in this JSON structure:
      {
        "priority_improvements": [
          {
            "section": "Section name (e.g., Summary, Experience)",
            "current_issue": "What's currently lacking",
            "recommendation": "Specific improvement suggestion",
            "impact": "How this helps job prospects",
            "priority": "high/medium/low"
          }
        ],
        "keyword_suggestions": [
          {
            "category": "Technical Skills",
            "keywords": ["keyword1", "keyword2"],
            "placement": "Where to add these keywords"
          }
        ],
        "content_improvements": {
          "headline": "Suggested improved headline",
          "summary_tips": ["Tip 1", "Tip 2"],
          "experience_tips": ["Tip 1", "Tip 2"]
        },
        "overall_strategy": "High-level advice for profile optimization"
      }

      Make recommendations specific to the user's industry and experience level.
    PROMPT
  end

  def parse_recommendations_response(content)
    JSON.parse(content)
  rescue JSON::ParserError => e
    Rails.logger.warn(
      message: "Failed to parse LinkedIn recommendations JSON",
      content: content,
      error: e.message
    )
    
    # Return fallback structure
    {
      "priority_improvements" => [
        {
          "section" => "Profile Analysis",
          "current_issue" => "Unable to parse AI recommendations",
          "recommendation" => "Please try uploading your LinkedIn profile again",
          "impact" => "Complete analysis will provide better insights",
          "priority" => "high"
        }
      ],
      "keyword_suggestions" => [],
      "content_improvements" => {
        "headline" => "Consider updating your professional headline",
        "summary_tips" => ["Add a compelling summary section"],
        "experience_tips" => ["Include quantified achievements"]
      },
      "overall_strategy" => "Focus on completing all profile sections with relevant keywords"
    }
  end
end