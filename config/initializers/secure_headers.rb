# Security headers configuration
SecureHeaders::Configuration.default do |config|
  # Basic security headers
  config.x_frame_options = "DENY"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = "strict-origin-when-cross-origin"

  # HSTS - HTTP Strict Transport Security
  config.hsts = "max-age=#{1.year.to_i}; includeSubDomains; preload"

  # Content Security Policy - allow inline scripts and styles for development
  config.csp = {
    default_src: %w('self'),
    script_src: %w('self' 'unsafe-inline' 'unsafe-eval'),
    style_src: %w('self' 'unsafe-inline'),
    img_src: %w('self' data: https:),
    font_src: %w('self' data: https:),
    connect_src: %w('self' https: wss:),
    frame_ancestors: %w('none'),
    object_src: %w('none')
  }
end
