class PromptSelection < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :application, optional: true
  
  validates :tone_preference, presence: true
  validates :main_strength, presence: true
  validates :experience_level, presence: true
  validates :career_motivation, presence: true
  
  # Ensure only one default profile per user
  validates :is_default_profile, uniqueness: { scope: :user_id }, if: :is_default_profile?
  
  scope :default_profiles, -> { where(is_default_profile: true) }
  scope :by_user, ->(user) { where(user: user) }
  scope :recent, -> { order(last_used_at: :desc, created_at: :desc) }
  scope :named, -> { where.not(profile_name: [nil, ""]) }

  before_save :set_default_profile_name
  before_save :ensure_single_default_per_user

  def display_name
    profile_name.presence || "Profile #{id}"
  end

  def summary
    "#{tone_preference} tone, #{experience_level} level, focused on #{main_strength}"
  end

  def recently_used?
    last_used_at.present? && last_used_at > 7.days.ago
  end

  def complete?
    [tone_preference, main_strength, experience_level, career_motivation].all?(&:present?)
  end

  # Check if this profile matches another profile
  def matches?(other_profile)
    return false unless other_profile.is_a?(PromptSelection)
    
    tone_preference == other_profile.tone_preference &&
    main_strength == other_profile.main_strength &&
    experience_level == other_profile.experience_level &&
    career_motivation == other_profile.career_motivation
  end

  # Create a copy of this profile for a specific application
  def copy_for_application(application)
    PromptSelection.create!(
      application: application,
      user: application.user,
      tone_preference: tone_preference,
      main_strength: main_strength,
      experience_level: experience_level,
      career_motivation: career_motivation,
      profile_name: "Copy of #{display_name}",
      last_used_at: Time.current
    )
  end

  # Update usage timestamp
  def mark_as_used!
    touch(:last_used_at)
  end

  private

  def set_default_profile_name
    if profile_name.blank? && is_default_profile?
      self.profile_name = "Default Profile"
    elsif profile_name.blank?
      self.profile_name = "Profile #{Time.current.strftime('%m/%d %H:%M')}"
    end
  end

  def ensure_single_default_per_user
    if is_default_profile? && user_id.present? && will_save_change_to_is_default_profile?
      # Remove default flag from other profiles for this user
      self.class.where(user_id: user_id, is_default_profile: true)
                .where.not(id: id)
                .update_all(is_default_profile: false)
    end
  end
end