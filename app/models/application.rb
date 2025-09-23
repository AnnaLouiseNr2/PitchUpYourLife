class Application < ApplicationRecord
  belongs_to :user
  has_one_attached :cv
  validates :job_d, presence: true

  has_many :finals, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :traits, dependent: :destroy

  # File upload security validations
  validates :cv, attached: true, content_type: {
    in: %w[application/pdf],
    message: 'must be a PDF file'
  }, size: { less_than: 10.megabytes, message: 'must be less than 10MB' }

end
