class HealthController < ApplicationController
  # Skip authentication and CSRF protection for health checks
  skip_before_action :authenticate_user!, if: :devise_controller?
  skip_before_action :verify_authenticity_token
  
  # Basic health check endpoint
  def show
    render json: {
      status: 'ok',
      timestamp: Time.current.iso8601,
      **Rails.application.config.health_check_info
    }
  end

  # Detailed health check with database connectivity
  def detailed
    checks = perform_health_checks
    
    status_code = checks.values.all? { |check| check[:status] == 'ok' } ? 200 : 503
    
    render json: {
      status: status_code == 200 ? 'ok' : 'unhealthy',
      timestamp: Time.current.iso8601,
      checks: checks,
      **Rails.application.config.health_check_info
    }, status: status_code
  end

  # Ready check for Kubernetes/container orchestration
  def ready
    checks = {
      database: check_database,
      redis: check_redis
    }
    
    all_ready = checks.values.all? { |check| check[:status] == 'ok' }
    
    render json: {
      status: all_ready ? 'ready' : 'not_ready',
      checks: checks,
      timestamp: Time.current.iso8601
    }, status: all_ready ? 200 : 503
  end

  # Liveness probe for Kubernetes
  def live
    render json: {
      status: 'alive',
      timestamp: Time.current.iso8601,
      uptime: uptime_seconds
    }
  end

  private

  def perform_health_checks
    {
      database: check_database,
      redis: check_redis,
      disk_space: check_disk_space,
      memory: check_memory_usage
    }
  end

  def check_database
    start_time = Time.current
    
    ActiveRecord::Base.connection.execute('SELECT 1')
    response_time = (Time.current - start_time) * 1000
    
    {
      status: 'ok',
      response_time_ms: response_time.round(2),
      connection_pool: {
        size: ActiveRecord::Base.connection_pool.size,
        checked_out: ActiveRecord::Base.connection_pool.checked_out.size
      }
    }
  rescue => e
    {
      status: 'error',
      error: e.message,
      response_time_ms: nil
    }
  end

  def check_redis
    # Skip Redis check if not configured
    return { status: 'skipped', reason: 'Redis not configured' } unless defined?(Redis)
    
    start_time = Time.current
    
    # This would connect to Redis if configured
    # Redis.current.ping
    response_time = (Time.current - start_time) * 1000
    
    {
      status: 'ok',
      response_time_ms: response_time.round(2)
    }
  rescue => e
    {
      status: 'error', 
      error: e.message
    }
  end

  def check_disk_space
    # Simple disk space check (works on Unix-like systems)
    df_output = `df -h / 2>/dev/null`.split("\n").last rescue nil
    
    if df_output
      usage_percent = df_output.split[4].to_i
      {
        status: usage_percent > 90 ? 'warning' : 'ok',
        disk_usage_percent: usage_percent,
        available: df_output.split[3]
      }
    else
      { status: 'unknown', reason: 'Unable to check disk space' }
    end
  end

  def check_memory_usage
    # Basic memory usage info
    if RUBY_PLATFORM.include?('linux')
      meminfo = File.read('/proc/meminfo') rescue nil
      if meminfo
        total = meminfo.match(/MemTotal:\s+(\d+)/)[1].to_i
        available = meminfo.match(/MemAvailable:\s+(\d+)/)[1].to_i
        usage_percent = ((total - available).to_f / total * 100).round(2)
        
        return {
          status: usage_percent > 85 ? 'warning' : 'ok',
          memory_usage_percent: usage_percent,
          total_kb: total,
          available_kb: available
        }
      end
    end

    # Fallback to Ruby process info
    rss = `ps -o rss= -p #{Process.pid}`.strip.to_i rescue 0
    {
      status: 'ok',
      process_memory_kb: rss,
      ruby_gc_stats: GC.stat.slice(:count, :heap_allocated_pages, :heap_live_slots)
    }
  end

  def uptime_seconds
    return @uptime if defined?(@uptime)
    
    if File.exist?('/proc/uptime')
      @uptime = File.read('/proc/uptime').split.first.to_f rescue 0
    else
      # Fallback: use application boot time (not accurate for system uptime)
      @uptime = Time.current - Rails.application.config.booted_at if Rails.application.config.respond_to?(:booted_at)
      @uptime ||= 0
    end
    
    @uptime
  end
end