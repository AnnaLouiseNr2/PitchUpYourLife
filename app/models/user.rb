class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :applications, dependent: :destroy
  has_many :clicks, dependent: :destroy
  has_many :prompt_selections, dependent: :destroy
  has_many :ml_predictions, dependent: :destroy

  def display_name
    email.split('@').first.humanize
  end

  def total_affiliate_clicks
    clicks.count
  end

  def affiliate_conversions
    clicks.converted.count
  end

  def conversion_rate
    return 0 if total_affiliate_clicks == 0
    
    (affiliate_conversions.to_f / total_affiliate_clicks * 100).round(2)
  end

  def total_affiliate_revenue
    clicks.converted.where.not(conversion_value: nil).sum(:conversion_value)
  end

  def recent_course_clicks(limit = 5)
    clicks.includes(:course)
          .where.not(course_id: nil)
          .order(clicked_at: :desc)
          .limit(limit)
  end

  def analyzed_applications
    applications.where.not(cv_analysis: nil)
  end

  def applications_needing_analysis
    applications.select(&:needs_reanalysis?)
  end
end
