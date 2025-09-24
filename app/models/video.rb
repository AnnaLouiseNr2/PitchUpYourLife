class Video < ApplicationRecord
  belongs_to :application
  has_one_attached :file

  # File upload security validations
  validate :file_content_type
  validate :file_size

  private

  def file_content_type
    return unless file.attached?

    allowed_types = %w[video/mp4 video/quicktime video/x-msvideo video/webm]
    unless allowed_types.include?(file.blob.content_type)
      errors.add(:file, 'must be a video file (MP4, MOV, AVI, or WebM)')
    end
  end

  def file_size
    return unless file.attached?

    if file.blob.byte_size > 100.megabytes
      errors.add(:file, 'must be less than 100MB')
    end
  end
end
