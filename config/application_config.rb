# Single Source of Truth for Application Configuration
# Centralizes all shared configurations, constants, and feature flags

class ApplicationConfig
  class << self
    # AI Service Configuration
    def openai_api_key
      Rails.application.credentials.dig(:openai, :api_key) || ENV['OPENAI_API_KEY']
    end

    def ai_service_timeout
      30.seconds
    end

    def ai_service_retry_attempts
      3
    end

    # LinkedIn Integration Configuration (Phase 3)
    def linkedin_client_id
      Rails.application.credentials.dig(:linkedin, :client_id) || ENV['LINKEDIN_CLIENT_ID']
    end

    def linkedin_client_secret
      Rails.application.credentials.dig(:linkedin, :client_secret) || ENV['LINKEDIN_CLIENT_SECRET']
    end

    def linkedin_redirect_uri
      "#{base_url}/auth/linkedin/callback"
    end

    # ML Service Configuration (Phase 3)
    def ml_service_endpoint
      Rails.application.credentials.dig(:ml_service, :endpoint) || ENV['ML_SERVICE_ENDPOINT']
    end

    def ml_service_api_key
      Rails.application.credentials.dig(:ml_service, :api_key) || ENV['ML_SERVICE_API_KEY']
    end

    def ml_batch_size
      100
    end

    # File Storage Configuration
    def cloudinary_url
      Rails.application.credentials.dig(:cloudinary, :url) || ENV['CLOUDINARY_URL']
    end

    def max_file_size
      10.megabytes
    end

    def allowed_file_types
      %w[pdf doc docx txt].freeze
    end

    # Affiliate Configuration
    def affiliate_commission_rates
      {
        'udemy' => 15.0,
        'coursera' => 20.0,
        'pluralsight' => 12.0,
        'acloudguru' => 25.0
      }.freeze
    end

    def affiliate_cookie_duration
      30.days
    end

    # Feature Flags (Phase 3)
    def linkedin_integration_enabled?
      Rails.env.production? ? 
        Rails.application.credentials.dig(:features, :linkedin_enabled) : 
        ENV['ENABLE_LINKEDIN'].present?
    end

    def ml_predictions_enabled?
      Rails.env.production? ? 
        Rails.application.credentials.dig(:features, :ml_enabled) : 
        ENV['ENABLE_ML'].present?
    end

    def enterprise_features_enabled?
      Rails.env.production? ? 
        Rails.application.credentials.dig(:features, :enterprise_enabled) : 
        ENV['ENABLE_ENTERPRISE'].present?
    end

    # Analytics Configuration
    def analytics_retention_period
      2.years
    end

    def analytics_batch_processing_size
      1000
    end

    # Performance Configuration
    def cache_expiry_short
      1.hour
    end

    def cache_expiry_medium
      6.hours
    end

    def cache_expiry_long
      24.hours
    end

    def job_queue_priorities
      {
        critical: 10,    # LinkedIn data sync, ML predictions
        high: 5,         # CV analysis, course recommendations  
        normal: 0,       # Cover letter generation
        low: -5          # Cleanup, maintenance
      }.freeze
    end

    # Enterprise Configuration (Phase 3)
    def enterprise_user_limit
      10000
    end

    def enterprise_api_rate_limit
      1000 # requests per hour
    end

    def enterprise_storage_limit
      1.terabyte
    end

    # Development/Testing Configuration
    def mock_external_services?
      Rails.env.test? || ENV['MOCK_SERVICES'].present?
    end

    def debug_ai_prompts?
      Rails.env.development? && ENV['DEBUG_AI'].present?
    end

    private

    def base_url
      Rails.env.production? ? 
        Rails.application.credentials.dig(:app, :base_url) : 
        "http://localhost:3000"
    end
  end
end