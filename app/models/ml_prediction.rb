class MlPrediction < ApplicationRecord
  belongs_to :user
  belongs_to :application
  
  validates :prediction_type, presence: true, inclusion: { in: %w[success_probability salary_range career_path] }
  validates :confidence_score, presence: true, numericality: { in: 0..1 }
  validates :status, inclusion: { in: %w[pending processing completed failed] }
  validates :model_version, presence: true
  
  # Scopes for querying predictions
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :recent, -> { where(created_at: 7.days.ago..Time.current) }
  scope :high_confidence, -> { where('confidence_score > ?', 0.8) }
  scope :by_type, ->(type) { where(prediction_type: type) }
  
  # Scope for user's recent predictions
  scope :for_user, ->(user) { where(user: user) }
  scope :for_application, ->(application) { where(application: application) }
  
  def completed?
    status == 'completed'
  end
  
  def failed?
    status == 'failed'
  end
  
  def high_confidence?
    confidence_score > 0.8
  end
  
  def processing_time_seconds
    return nil unless processing_duration_ms.present?
    
    processing_duration_ms / 1000.0
  end
  
  # Get formatted results based on prediction type
  def formatted_results
    case prediction_type
    when 'success_probability'
      format_success_probability
    when 'salary_range'
      format_salary_range
    when 'career_path'
      format_career_paths
    else
      {}
    end
  end
  
  # Get human-readable confidence level
  def confidence_level
    case confidence_score
    when 0.0..0.3
      'Low'
    when 0.3..0.7
      'Moderate'
    when 0.7..1.0
      'High'
    else
      'Unknown'
    end
  end
  
  # Check if prediction is stale and needs updating
  def stale?
    return false if processed_at.blank?
    
    processed_at < 7.days.ago
  end
  
  private
  
  def format_success_probability
    return {} unless success_probability.present?
    
    percentage = (success_probability * 100).round(1)
    
    {
      percentage: percentage,
      display: "#{percentage}%",
      level: case percentage
             when 0..30 then 'Low'
             when 30..70 then 'Moderate' 
             when 70..100 then 'High'
             else 'Unknown'
             end,
      confidence: confidence_level
    }
  end
  
  def format_salary_range
    return {} unless salary_prediction.present?
    
    min_salary = salary_prediction['min']
    max_salary = salary_prediction['max']
    currency = salary_prediction['currency'] || 'USD'
    
    {
      min: min_salary,
      max: max_salary,
      currency: currency,
      range_display: "#{format_currency(min_salary, currency)} - #{format_currency(max_salary, currency)}",
      estimated: salary_prediction['estimated'],
      estimated_display: format_currency(salary_prediction['estimated'], currency),
      confidence: confidence_level
    }
  end
  
  def format_career_paths
    return {} unless career_paths.present?
    
    paths = career_paths.map do |path|
      {
        type: path['path_type'],
        title: path['title'],
        timeline: path['timeline'],
        probability: path['probability'],
        probability_display: "#{(path['probability'] * 100).round}%",
        requirements: path['requirements'],
        salary_increase: path['salary_increase']
      }
    end
    
    {
      paths: paths,
      count: paths.count,
      top_path: paths.first,
      confidence: confidence_level
    }
  end
  
  def format_currency(amount, currency = 'USD')
    return 'N/A' unless amount.present?
    
    case currency.upcase
    when 'USD'
      "$#{amount.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, ',')}"
    when 'EUR'
      "€#{amount.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, ',')}"
    when 'GBP'
      "£#{amount.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, ',')}"
    else
      "#{amount.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, ',')} #{currency}"
    end
  end
end