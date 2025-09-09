class Final < ApplicationRecord
  belongs_to :application
  belongs_to :finalized_by_user, class_name: 'User', optional: true
  
  validates :application_id, presence: true
  validates :coverletter_version, :pitch_version, presence: true, numericality: { greater_than: 0 }
  
  scope :current, -> { where(is_current: true) }
  scope :finalized, -> { where.not(finalized_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  
  before_save :calculate_word_counts
  before_save :ensure_single_current_per_application
  
  def finalized?
    finalized_at.present?
  end
  
  def finalize!(user = nil)
    update!(
      finalized_at: Time.current,
      finalized_by_user: user,
      is_current: true
    )
  end
  
  def content_ready?
    coverletter_content.present? && pitch.present?
  end
  
  private
  
  def calculate_word_counts
    self.coverletter_word_count = coverletter_content.present? ? coverletter_content.split.size : 0
    self.pitch_word_count = pitch.present? ? pitch.split.size : 0
  end
  
  def ensure_single_current_per_application
    if is_current? && will_save_change_to_is_current?
      self.class.where(application_id: application_id, is_current: true)
                .where.not(id: id)
                .update_all(is_current: false)
    end
  end
end
