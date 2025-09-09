class Course < ApplicationRecord
  has_many :clicks, dependent: :destroy
  
  validates :title, presence: true
  validates :provider, presence: true
  validates :affiliate_url, presence: true, format: URI::DEFAULT_PARSER.make_regexp
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :affiliate_commission_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :difficulty_level, inclusion: { in: ['beginner', 'intermediate', 'advanced', 'expert'] }, allow_nil: true
  validates :enrolled_count, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :by_provider, ->(provider) { where(provider: provider) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_difficulty, ->(level) { where(difficulty_level: level) }
  scope :by_rating_above, ->(rating) { where('rating >= ?', rating) }
  scope :with_skills, ->(skills) { where('skills && ?', "{#{Array(skills).join(',')}}") }
  
  # Search courses by skills overlap
  scope :matching_skills, ->(skills_array) do
    skills_string = "{#{Array(skills_array).join(',')}}"
    where('skills && ?', skills_string)
      .order(Arel.sql("array_length(skills & '#{skills_string}', 1) DESC NULLS LAST"))
  end

  # Get top rated courses
  scope :top_rated, -> { where.not(rating: nil).order(rating: :desc) }
  
  # Get popular courses
  scope :popular, -> { order(enrolled_count: :desc) }

  def skill_list
    skills.join(', ')
  end

  def formatted_price
    return 'Free' if price.nil? || price == 0
    "#{currency} #{price}"
  end

  def difficulty_badge_color
    case difficulty_level
    when 'beginner' then 'success'
    when 'intermediate' then 'warning' 
    when 'advanced' then 'danger'
    when 'expert' then 'dark'
    else 'secondary'
    end
  end

  def estimated_completion_text
    return 'Duration not specified' if duration_hours.nil?
    
    if duration_hours < 1
      "#{(duration_hours * 60).to_i} minutes"
    elsif duration_hours < 40
      "#{duration_hours} hours"
    else
      weeks = (duration_hours / 10.0).ceil # Assuming 10 hours per week
      "#{weeks} #{'week'.pluralize(weeks)}"
    end
  end

  # Get affiliate link with tracking
  def tracked_affiliate_url(user, click_tracking_service = nil)
    return affiliate_url unless click_tracking_service
    
    result = click_tracking_service.track_click(affiliate_url, {})
    result[:success] ? result[:tracked_url] : affiliate_url
  end

  # Check if course teaches specific skill
  def teaches_skill?(skill)
    skills.any? { |s| s.downcase.include?(skill.downcase) }
  end

  # Get skills that match a provided list
  def matching_skills(skill_list)
    return [] if skills.blank? || skill_list.blank?
    
    skills & Array(skill_list).map(&:downcase)
  end

  # Calculate relevance score for a given skills array
  def relevance_score_for(required_skills)
    return 0 if required_skills.blank?
    
    matches = matching_skills(required_skills).count
    base_score = matches * 10
    
    # Bonus for rating
    rating_bonus = rating ? (rating * 2).to_i : 0
    
    # Bonus for popularity 
    popularity_bonus = enrolled_count > 1000 ? 5 : 0
    
    base_score + rating_bonus + popularity_bonus
  end
end