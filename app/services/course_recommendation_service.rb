require "ruby_llm"

# Service class for course recommendations based on skills gap analysis
# Integrates with affiliate marketing and click tracking
class CourseRecommendationService
  def initialize(application)
    @application = application
  end

  # Get course recommendations based on skills gap analysis
  def recommend_courses
    ActiveSupport::Notifications.instrument(
      'ai_content_generation.application',
      service: 'CourseRecommendationService',
      method: 'recommend_courses',
      application_id: @application.id
    ) do |payload|
      
      # Get skills gap analysis first
      profile_service = ProfileAnalysisService.new(@application)
      skills_result = profile_service.analyze_skills_gap
      
      unless skills_result[:success]
        return {
          success: false,
          courses: [],
          error: "Skills analysis failed: #{skills_result[:error]}"
        }
      end

      skills_gap = skills_result[:skills_gap]
      recommended_courses = find_matching_courses(skills_gap)
      
      payload[:success] = true
      payload[:courses_found] = recommended_courses.count
      
      {
        success: true,
        courses: recommended_courses,
        skills_analysis: skills_gap,
        error: nil
      }
    end
  rescue => e
    Rails.logger.error(
      message: "Course recommendation failed",
      service: 'CourseRecommendationService',
      method: 'recommend_courses',
      application_id: @application.id,
      error: e.message,
      backtrace: e.backtrace&.first(5)
    )
    
    {
      success: false,
      courses: [],
      error: e.message
    }
  end

  # Get personalized course recommendations with AI enhancement
  def get_personalized_recommendations
    ActiveSupport::Notifications.instrument(
      'ai_content_generation.application',
      service: 'CourseRecommendationService', 
      method: 'get_personalized_recommendations',
      application_id: @application.id
    ) do |payload|
      
      cv_text = extract_cv_text
      job_description = @application.job_d
      
      # Get base course recommendations
      base_result = recommend_courses
      unless base_result[:success]
        return base_result
      end

      available_courses = base_result[:courses]
      skills_analysis = base_result[:skills_analysis]
      
      # Use AI to personalize and prioritize recommendations
      personalization_prompt = build_personalization_prompt(skills_analysis, available_courses)
      chat = RubyLLM.chat
      chat.with_instructions(personalization_prompt)
      
      response = chat.ask(
        "Personalize course recommendations for this profile. " \
        "CV: #{cv_text} " \
        "Job Description: #{job_description} " \
        "Available Courses: #{available_courses.to_json}"
      )
      
      personalized_recommendations = parse_personalization_response(response.content, available_courses)
      
      payload[:success] = true
      payload[:personalized_courses] = personalized_recommendations.count
      
      {
        success: true,
        courses: personalized_recommendations,
        skills_analysis: skills_analysis,
        personalization_rationale: extract_rationale(response.content),
        error: nil
      }
    end
  rescue => e
    Rails.logger.error(
      message: "Personalized course recommendation failed",
      service: 'CourseRecommendationService',
      method: 'get_personalized_recommendations', 
      application_id: @application.id,
      error: e.message,
      backtrace: e.backtrace&.first(5)
    )
    
    {
      success: false,
      courses: [],
      error: e.message
    }
  end

  private

  def extract_cv_text
    CvTextExtractor.call(@application)
  end

  def find_matching_courses(skills_gap)
    missing_technical_skills = skills_gap.dig("technical_skills", "missing") || []
    weak_technical_skills = skills_gap.dig("technical_skills", "weak") || []
    learning_priorities = skills_gap["learning_priorities"] || []
    recommended_categories = skills_gap.dig("recommended_courses") || []
    
    # Get all relevant skills to search for
    all_skills = (missing_technical_skills + weak_technical_skills).uniq
    priority_skills = learning_priorities.map { |lp| lp["skill"] }.compact
    
    # Build the query to find courses
    courses = Course.active
    
    # Filter by skills (using PostgreSQL array overlap)
    if all_skills.any?
      courses = courses.where("skills && ?", "{#{all_skills.join(',')}}")
    end
    
    # Prioritize courses that teach high-priority skills
    if priority_skills.any?
      courses = courses.order(
        Arel.sql("CASE WHEN skills && '#{"{#{priority_skills.join(',')}}"}' THEN 0 ELSE 1 END")
      )
    end
    
    # Order by rating and popularity
    courses = courses.order(rating: :desc, enrolled_count: :desc)
    
    # Limit to top recommendations
    courses.limit(10).map do |course|
      {
        id: course.id,
        title: course.title,
        provider: course.provider,
        description: course.description,
        skills: course.skills,
        rating: course.rating,
        enrolled_count: course.enrolled_count,
        duration_hours: course.duration_hours,
        difficulty_level: course.difficulty_level,
        affiliate_url: course.affiliate_url,
        price: course.price,
        currency: course.currency,
        image_url: course.image_url,
        relevance_score: calculate_relevance_score(course, all_skills, priority_skills)
      }
    end
  end

  def calculate_relevance_score(course, all_skills, priority_skills)
    skill_matches = (course.skills & all_skills).count
    priority_matches = (course.skills & priority_skills).count
    
    base_score = skill_matches * 10
    priority_bonus = priority_matches * 20
    rating_bonus = course.rating ? (course.rating * 2).to_i : 0
    
    base_score + priority_bonus + rating_bonus
  end

  def build_personalization_prompt(skills_analysis, available_courses)
    <<~PROMPT
      You are a career development expert specializing in personalized learning paths.
      
      Given a candidate's skills analysis and available courses, provide personalized recommendations
      that prioritize the most impactful learning for their career goals.

      Consider:
      1. Skills gap urgency (high-priority missing skills first)
      2. Learning sequence (prerequisites and logical progression)
      3. Time investment vs. career impact
      4. Candidate's current skill level
      5. Job market demand

      Return recommendations in this JSON structure:
      {
        "personalized_courses": [
          {
            "course_id": 123,
            "priority_rank": 1,
            "rationale": "Critical for job requirements, builds on existing skills",
            "learning_path_position": "foundation",
            "estimated_completion_weeks": 4,
            "career_impact": "high"
          }
        ],
        "learning_path_summary": "Start with foundational React course, then advanced concepts",
        "total_estimated_time": "12-16 weeks",
        "expected_outcomes": ["Qualify for React developer roles", "Increase salary potential by 20%"]
      }

      Focus on actionable, career-focused recommendations that maximize the candidate's job prospects.
    PROMPT
  end

  def parse_personalization_response(content, available_courses)
    parsed = JSON.parse(content)
    personalized_courses = parsed["personalized_courses"] || []
    
    # Match AI recommendations with actual course data
    personalized_courses.map do |rec|
      course = available_courses.find { |c| c[:id] == rec["course_id"] }
      next unless course
      
      course.merge(
        priority_rank: rec["priority_rank"],
        rationale: rec["rationale"],
        learning_path_position: rec["learning_path_position"],
        estimated_completion_weeks: rec["estimated_completion_weeks"],
        career_impact: rec["career_impact"]
      )
    end.compact.sort_by { |c| c[:priority_rank] || 999 }
    
  rescue JSON::ParserError => e
    Rails.logger.warn(
      message: "Failed to parse course personalization JSON response",
      content: content,
      error: e.message
    )
    
    # Return courses with basic prioritization as fallback
    available_courses.sort_by { |c| -c[:relevance_score] }
  end

  def extract_rationale(content)
    parsed = JSON.parse(content)
    {
      learning_path_summary: parsed["learning_path_summary"],
      total_estimated_time: parsed["total_estimated_time"], 
      expected_outcomes: parsed["expected_outcomes"]
    }
  rescue JSON::ParserError
    {
      learning_path_summary: "Courses recommended based on skills gap analysis",
      total_estimated_time: "Varies by course selection",
      expected_outcomes: ["Improved job qualifications", "Enhanced skill set"]
    }
  end
end