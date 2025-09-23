class Video < ApplicationRecord
  belongs_to :application
  has_one_attached :file

  # File upload security validations
  validates :file, attached: true, content_type: {
    in: %w[video/mp4 video/quicktime video/x-msvideo video/webm],
    message: 'must be a video file (MP4, MOV, AVI, or WebM)'
  }, size: { less_than: 100.megabytes, message: 'must be less than 100MB' }
end
