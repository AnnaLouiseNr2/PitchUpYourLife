class Application < ApplicationRecord
  belongs_to :user
  has_one_attached :cv
  validates :job_d, presence: true

  has_many :finals, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :prompt_selections, dependent: :destroy
  has_many :clicks, dependent: :destroy
  has_many :ml_predictions, dependent: :destroy

  # CV analysis functionality
  def analyzed?
    cv_analysis.present? && analyzed_at.present?
  end

  def needs_reanalysis?
    return true unless analyzed?
    
    # Check if analysis is older than 7 days
    analyzed_at < 7.days.ago
  end

  def analysis_score
    return 0 unless cv_analysis.present?
    
    cv_analysis.dig('matching_score') || 0
  end

  def missing_keywords
    return [] unless cv_analysis.present?
    
    cv_analysis.dig('ats_keywords', 'missing') || []
  end

  def present_keywords
    return [] unless cv_analysis.present?
    
    cv_analysis.dig('ats_keywords', 'present') || []
  end

  def content_quality_score
    return 0 unless cv_analysis.present?
    
    cv_analysis.dig('content_quality', 'score') || 0
  end

  def skills_gap_summary
    return {} unless skills_gap_analysis.present?
    
    {
      missing_technical: skills_gap_analysis.dig('technical_skills', 'missing') || [],
      missing_soft: skills_gap_analysis.dig('soft_skills', 'missing') || [],
      learning_priorities: skills_gap_analysis.dig('learning_priorities') || []
    }
  end

  def recommended_course_categories
    return [] unless skills_gap_analysis.present?
    
    skills_gap_analysis.dig('recommended_courses')&.map { |course| course['category'] }&.compact || []
  end

  def priority_skills_to_learn
    return [] unless skills_gap_analysis.present?
    
    priorities = skills_gap_analysis.dig('learning_priorities') || []
    priorities.select { |p| p['importance'] == 'high' }
             .map { |p| p['skill'] }
  end

  def current_prompt_selection
    prompt_selections.order(created_at: :desc).first
  end

  def coverletter_ready?
    coverletter_status == 'completed' && coverletter_message.present?
  end

  def video_pitch_ready?
    video_status == 'completed' && video_message.present?
  end

  def current_final
    finals.where(is_current: true).first || finals.order(created_at: :desc).first
  end

  # ML prediction methods
  def has_predictions?
    ml_predictions.completed.any?
  end

  def success_prediction
    ml_predictions.completed.by_type('success_probability').order(created_at: :desc).first
  end

  def salary_prediction
    ml_predictions.completed.by_type('salary_range').order(created_at: :desc).first
  end

  def career_paths_prediction
    ml_predictions.completed.by_type('career_path').order(created_at: :desc).first
  end

  def predictions_stale?
    return true unless has_predictions?
    
    ml_predictions.completed.any?(&:stale?)
  end

  def prediction_summary
    return nil unless has_predictions?

    success = success_prediction
    salary = salary_prediction
    career = career_paths_prediction

    {
      success_probability: success&.formatted_results,
      salary_range: salary&.formatted_results,
      career_paths: career&.formatted_results,
      last_updated: [success&.processed_at, salary&.processed_at, career&.processed_at].compact.max
    }
  end
end
