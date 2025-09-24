class Application < ApplicationRecord
  belongs_to :user
  has_one_attached :cv
  validates :job_d, presence: true

  has_many :finals, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :prompt_selections, dependent: :destroy

  # File upload security validations
  validates :cv, presence: true
  validate :cv_content_type
  validate :cv_file_size

  private

  def cv_content_type
    return unless cv.attached?

    unless cv.blob.content_type == 'application/pdf'
      errors.add(:cv, 'must be a PDF file')
    end
  end

  def cv_file_size
    return unless cv.attached?

    if cv.blob.byte_size > 10.megabytes
      errors.add(:cv, 'must be less than 10MB')
    end
  end

end
