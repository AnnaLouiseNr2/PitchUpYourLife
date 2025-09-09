# ML Prediction Service for Career Success Predictions
# Phase 3: Advanced ML predictions without external API dependencies

class MlPredictionService
  def initialize(user, application)
    @user = user
    @application = application
  end

  # Generate success probability prediction for job application
  def predict_success_probability
    ActiveSupport::Notifications.instrument(
      'ml_prediction.application',
      service: 'MlPredictionService',
      method: 'predict_success_probability',
      user_id: @user.id,
      application_id: @application.id
    ) do |payload|
      
      # Gather features for ML prediction
      features = extract_features_for_prediction
      
      # Calculate success probability using rule-based model
      # TODO: Replace with actual ML model API call when available
      success_score = calculate_success_probability(features)
      confidence = calculate_confidence_score(features)
      
      # Store prediction in database
      prediction = create_ml_prediction(
        prediction_type: 'success_probability',
        success_probability: success_score,
        confidence_score: confidence,
        input_features: features
      )
      
      payload[:success] = true
      payload[:prediction_id] = prediction.id
      payload[:success_score] = success_score
      
      {
        success: true,
        prediction: prediction,
        success_probability: success_score,
        confidence_score: confidence,
        features_used: features.keys,
        error: nil
      }
    end
  rescue => e
    Rails.logger.error(
      message: "ML success prediction failed",
      service: 'MlPredictionService',
      method: 'predict_success_probability',
      user_id: @user.id,
      application_id: @application.id,
      error: e.message,
      backtrace: e.backtrace&.first(5)
    )
    
    {
      success: false,
      prediction: nil,
      error: e.message
    }
  end

  # Predict salary range for the application
  def predict_salary_range
    ActiveSupport::Notifications.instrument(
      'ml_prediction.application',
      service: 'MlPredictionService',
      method: 'predict_salary_range',
      user_id: @user.id,
      application_id: @application.id
    ) do |payload|
      
      features = extract_features_for_prediction
      salary_data = calculate_salary_prediction(features)
      confidence = calculate_confidence_score(features)
      
      prediction = create_ml_prediction(
        prediction_type: 'salary_range',
        salary_prediction: salary_data,
        confidence_score: confidence,
        input_features: features
      )
      
      payload[:success] = true
      payload[:prediction_id] = prediction.id
      payload[:salary_range] = "#{salary_data['min']} - #{salary_data['max']} #{salary_data['currency']}"
      
      {
        success: true,
        prediction: prediction,
        salary_prediction: salary_data,
        confidence_score: confidence,
        error: nil
      }
    end
  rescue => e
    Rails.logger.error(
      message: "ML salary prediction failed",
      service: 'MlPredictionService',
      user_id: @user.id,
      application_id: @application.id,
      error: e.message
    )
    
    {
      success: false,
      prediction: nil,
      error: e.message
    }
  end

  # Predict career path recommendations
  def predict_career_paths
    ActiveSupport::Notifications.instrument(
      'ml_prediction.application',
      service: 'MlPredictionService',
      method: 'predict_career_paths',
      user_id: @user.id,
      application_id: @application.id
    ) do |payload|
      
      features = extract_features_for_prediction
      career_paths = generate_career_path_predictions(features)
      confidence = calculate_confidence_score(features)
      
      prediction = create_ml_prediction(
        prediction_type: 'career_path',
        career_paths: career_paths,
        confidence_score: confidence,
        input_features: features
      )
      
      payload[:success] = true
      payload[:prediction_id] = prediction.id
      payload[:paths_count] = career_paths.count
      
      {
        success: true,
        prediction: prediction,
        career_paths: career_paths,
        confidence_score: confidence,
        error: nil
      }
    end
  rescue => e
    Rails.logger.error(
      message: "ML career path prediction failed",
      service: 'MlPredictionService',
      user_id: @user.id,
      application_id: @application.id,
      error: e.message
    )
    
    {
      success: false,
      prediction: nil,
      error: e.message
    }
  end

  # Generate all predictions for an application
  def generate_comprehensive_predictions
    results = {}
    
    results[:success_probability] = predict_success_probability
    results[:salary_range] = predict_salary_range
    results[:career_paths] = predict_career_paths
    
    {
      success: results.values.all? { |r| r[:success] },
      predictions: results,
      summary: generate_predictions_summary(results)
    }
  end

  private

  def extract_features_for_prediction
    features = {
      # Application-specific features
      job_title_match: calculate_job_title_match,
      skills_match_percentage: calculate_skills_match,
      experience_relevance: calculate_experience_relevance,
      
      # User profile features
      total_applications: @user.applications.count,
      cv_quality_score: @application.content_quality_score,
      matching_score: @application.analysis_score,
      
      # Content generation features
      coverletter_ready: @application.coverletter_ready?,
      video_ready: @application.video_pitch_ready?,
      profile_completeness: calculate_profile_completeness,
      
      # Time-based features
      application_age_days: (@application.created_at ? (Time.current - @application.created_at) / 1.day : 0),
      user_activity_score: calculate_user_activity_score,
      
      # Skills gap features
      missing_skills_count: @application.missing_keywords.count,
      priority_skills_missing: @application.priority_skills_to_learn.count
    }
    
    features.compact
  end

  def calculate_success_probability(features)
    # Rule-based success probability calculation
    # TODO: Replace with trained ML model
    
    base_score = 0.5 # 50% baseline
    
    # Skills matching bonus
    skills_bonus = (features[:skills_match_percentage] || 0) * 0.003 # Up to 30% bonus
    
    # CV quality bonus
    cv_bonus = (features[:cv_quality_score] || 0) * 0.001 # Up to 10% bonus
    
    # Profile completeness bonus
    profile_bonus = (features[:profile_completeness] || 0) * 0.001 # Up to 10% bonus
    
    # Penalties for gaps
    skills_gap_penalty = (features[:missing_skills_count] || 0) * 0.02 # -2% per missing skill
    
    # Experience relevance
    experience_bonus = (features[:experience_relevance] || 0) * 0.002
    
    final_score = base_score + skills_bonus + cv_bonus + profile_bonus + experience_bonus - skills_gap_penalty
    
    # Clamp between 0.0 and 1.0
    [[final_score, 0.0].max, 1.0].min.round(4)
  end

  def calculate_salary_prediction(features)
    # Rule-based salary prediction
    # TODO: Replace with market data and ML model
    
    base_salary = 60000 # Base salary
    
    # Experience level adjustments
    experience_multiplier = case features[:experience_relevance] || 0
                          when 0..30 then 0.8    # Junior: -20%
                          when 31..60 then 1.0   # Mid: baseline
                          when 61..80 then 1.3   # Senior: +30%
                          else 1.6              # Executive: +60%
                          end
    
    # Skills premium
    skills_premium = (features[:skills_match_percentage] || 0) * 0.002 # Up to 20% premium
    
    # Location adjustments (simplified)
    location_multiplier = 1.1 # Assume 10% above average location
    
    estimated_salary = base_salary * experience_multiplier * location_multiplier * (1 + skills_premium)
    
    # Calculate range (±15%)
    min_salary = (estimated_salary * 0.85).to_i
    max_salary = (estimated_salary * 1.15).to_i
    
    {
      'min' => min_salary,
      'max' => max_salary,
      'currency' => 'USD',
      'estimated' => estimated_salary.to_i,
      'confidence' => 'moderate'
    }
  end

  def generate_career_path_predictions(features)
    # Generate career path recommendations based on current profile
    skills_match = features[:skills_match_percentage] || 0
    experience_level = features[:experience_relevance] || 0
    
    paths = []
    
    # Current role progression
    paths << {
      'path_type' => 'vertical_progression',
      'title' => 'Senior ' + (@application.title || 'Professional'),
      'timeline' => '1-2 years',
      'probability' => calculate_path_probability(skills_match, experience_level),
      'requirements' => ['Gain additional experience', 'Develop leadership skills'],
      'salary_increase' => '15-25%'
    }
    
    # Lateral move options
    if skills_match > 70
      paths << {
        'path_type' => 'lateral_move',
        'title' => 'Similar role in different industry',
        'timeline' => '6-12 months', 
        'probability' => (skills_match / 100.0).round(2),
        'requirements' => ['Industry knowledge', 'Network building'],
        'salary_increase' => '5-15%'
      }
    end
    
    # Specialization path
    if experience_level > 50
      paths << {
        'path_type' => 'specialization',
        'title' => 'Subject Matter Expert',
        'timeline' => '2-3 years',
        'probability' => 0.6,
        'requirements' => ['Deep specialization', 'Thought leadership'],
        'salary_increase' => '20-35%'
      }
    end
    
    paths.first(3) # Return top 3 paths
  end

  def calculate_confidence_score(features)
    # Calculate confidence based on available data quality
    confidence_factors = []
    
    confidence_factors << 0.2 if features[:cv_quality_score] && features[:cv_quality_score] > 70
    confidence_factors << 0.2 if features[:skills_match_percentage] && features[:skills_match_percentage] > 50
    confidence_factors << 0.2 if features[:profile_completeness] && features[:profile_completeness] > 80
    confidence_factors << 0.2 if features[:coverletter_ready] && features[:video_ready]
    confidence_factors << 0.2 if features[:matching_score] && features[:matching_score] > 75
    
    base_confidence = confidence_factors.sum
    [[base_confidence, 0.1].max, 1.0].min.round(2)
  end

  def create_ml_prediction(prediction_data)
    MlPrediction.create!(
      user: @user,
      application: @application,
      prediction_type: prediction_data[:prediction_type],
      success_probability: prediction_data[:success_probability],
      salary_prediction: prediction_data[:salary_prediction],
      career_paths: prediction_data[:career_paths],
      confidence_score: prediction_data[:confidence_score],
      model_version: '1.0.0',
      model_metadata: {
        'algorithm' => 'rule_based_v1',
        'features_count' => prediction_data[:input_features].keys.count,
        'generated_at' => Time.current.iso8601
      },
      input_features: prediction_data[:input_features],
      status: 'completed',
      processed_at: Time.current,
      processing_duration_ms: 50 # Simulated processing time
    )
  end

  # Feature calculation helpers
  def calculate_job_title_match
    return 0 unless @application.title.present?
    
    # Simple word overlap calculation
    job_words = @application.job_d.downcase.split(/\W+/).reject(&:empty?)
    title_words = @application.title.downcase.split(/\W+/).reject(&:empty?)
    
    overlap = (job_words & title_words).count
    total_words = [job_words.count, title_words.count].max
    
    total_words > 0 ? (overlap.to_f / total_words * 100).round(2) : 0
  end

  def calculate_skills_match
    return 0 unless @application.analyzed?
    
    present_keywords = @application.present_keywords.count
    missing_keywords = @application.missing_keywords.count
    total_keywords = present_keywords + missing_keywords
    
    return 0 if total_keywords == 0
    
    (present_keywords.to_f / total_keywords * 100).round(2)
  end

  def calculate_experience_relevance
    # Simplified experience relevance calculation
    # TODO: Enhance with actual CV parsing and job description matching
    return 50 unless @application.analyzed?
    
    # Use CV analysis score as proxy for experience relevance
    @application.analysis_score
  end

  def calculate_profile_completeness
    completeness = 0
    completeness += 20 if @application.coverletter_message.present?
    completeness += 20 if @application.video_message.present?
    completeness += 30 if @application.cv.attached?
    completeness += 15 if @application.current_prompt_selection.present?
    completeness += 15 if @application.analyzed?
    
    completeness
  end

  def calculate_user_activity_score
    # User engagement and activity scoring
    recent_applications = @user.applications.where(created_at: 30.days.ago..Time.current).count
    total_applications = @user.applications.count
    
    activity_score = recent_applications * 10 + total_applications * 2
    [activity_score, 100].min
  end

  def calculate_path_probability(skills_match, experience_level)
    base_prob = 0.3
    skills_bonus = (skills_match / 100.0) * 0.4
    experience_bonus = (experience_level / 100.0) * 0.3
    
    [[base_prob + skills_bonus + experience_bonus, 0.1].max, 0.95].min.round(2)
  end

  def generate_predictions_summary(results)
    summary = {
      'overall_score' => 'moderate',
      'key_insights' => [],
      'action_items' => []
    }
    
    # Success probability insights
    if results[:success_probability][:success]
      success_score = results[:success_probability][:success_probability]
      
      if success_score > 0.8
        summary['overall_score'] = 'excellent'
        summary['key_insights'] << 'High probability of application success'
      elsif success_score > 0.6
        summary['overall_score'] = 'good'
        summary['key_insights'] << 'Good chances with some improvements needed'
      else
        summary['overall_score'] = 'needs_improvement'
        summary['key_insights'] << 'Significant improvements needed for better success odds'
        summary['action_items'] << 'Focus on skills gap reduction'
      end
    end
    
    # Salary insights
    if results[:salary_range][:success]
      salary_data = results[:salary_range][:salary_prediction]
      summary['key_insights'] << "Estimated salary range: #{salary_data['min']} - #{salary_data['max']} #{salary_data['currency']}"
    end
    
    # Career path insights
    if results[:career_paths][:success]
      paths_count = results[:career_paths][:career_paths].count
      summary['key_insights'] << "#{paths_count} career advancement paths identified"
    end
    
    summary
  end
end