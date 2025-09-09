# Observability Configuration
# Set up structured logging, error tracking, and monitoring

Rails.application.configure do
  # Enhanced logging for production
  if Rails.env.production?
    # Use structured logging format
    config.log_formatter = proc do |severity, datetime, progname, msg|
      {
        timestamp: datetime.iso8601,
        level: severity,
        pid: Process.pid,
        source: progname,
        message: msg,
        environment: Rails.env,
        version: Rails.application.class.module_parent_name
      }.to_json + "\n"
    end
    
    # Log to stdout for containerized deployments
    config.logger = ActiveSupport::Logger.new(STDOUT)
    config.log_level = :info
  end

  # Configure Active Record logging
  config.active_record.logger = Rails.logger
  
  # Log slow queries in development/staging
  unless Rails.env.production?
    config.active_record.verbose_query_logs = true
  end
end

# Custom log tags for request tracking
Rails.application.configure do
  config.log_tags = [
    :request_id,
    -> (request) { "IP:#{request.remote_ip}" },
    -> (request) { "User:#{request.session[:user_id] || 'anonymous'}" }
  ]
end

# Performance monitoring setup
if defined?(ActiveSupport::Notifications)
  # Track AI service calls
  ActiveSupport::Notifications.subscribe('ai_content_generation.application') do |name, start, finish, id, payload|
    duration = finish - start
    Rails.logger.info(
      message: "AI content generation",
      service: payload[:service],
      method: payload[:method],
      duration_ms: (duration * 1000).round(2),
      success: payload[:success],
      application_id: payload[:application_id]
    )
  end

  # Track database performance
  ActiveSupport::Notifications.subscribe('sql.active_record') do |name, start, finish, id, payload|
    duration = finish - start
    
    # Only log slow queries (>100ms)
    if duration > 0.1
      Rails.logger.warn(
        message: "Slow query detected",
        sql: payload[:sql],
        duration_ms: (duration * 1000).round(2),
        connection_id: payload[:connection_id]
      )
    end
  end

  # Track job performance  
  ActiveSupport::Notifications.subscribe('perform.active_job') do |name, start, finish, id, payload|
    duration = finish - start
    Rails.logger.info(
      message: "Background job completed",
      job_class: payload[:job].class.name,
      job_id: payload[:job].job_id,
      queue: payload[:job].queue_name,
      duration_ms: (duration * 1000).round(2),
      arguments: payload[:job].arguments
    )
  end
end

# Health check endpoint data
Rails.application.config.health_check_info = {
  app_name: Rails.application.class.module_parent_name.downcase,
  version: ENV['APP_VERSION'] || 'development',
  rails_version: Rails.version,
  ruby_version: RUBY_VERSION,
  environment: Rails.env
}

# Error context for better debugging
if defined?(Rails.logger)
  module ErrorContext
    def self.add_context(error, context = {})
      error.define_singleton_method(:context) { context }
      error
    end

    def self.log_error(error, context = {})
      Rails.logger.error(
        message: "Application error",
        error_class: error.class.name,
        error_message: error.message,
        backtrace: error.backtrace&.first(10),
        context: context,
        timestamp: Time.current.iso8601
      )
    end
  end
end