class PromptSelection < ApplicationRecord
  belongs_to :application
  belongs_to :user, optional: true

  validates :tone_preference, presence: true, on: :update
  validates :main_strength, presence: true, on: :update
  validates :experience_level, presence: true, on: :update
  validates :career_motivation, presence: true, on: :update
end