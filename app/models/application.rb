class Application < ApplicationRecord
  belongs_to :user
  has_one_attached :cv
  validates :job_d, presence: true

  has_many :finals, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :traits, dependent: :destroy
end
