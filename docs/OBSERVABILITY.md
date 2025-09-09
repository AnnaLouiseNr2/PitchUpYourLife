# Observability & Monitoring

This document outlines the observability infrastructure for monitoring application health, performance, and debugging.

## Health Checks

### Endpoints

| Endpoint | Purpose | Response Format |
|----------|---------|-----------------|
| `GET /health` | Basic health status | `{"status": "ok", "timestamp": "..."}` |
| `GET /health/detailed` | Comprehensive health checks | Database, memory, disk checks |
| `GET /ready` | Kubernetes readiness probe | Service dependencies ready |
| `GET /live` | Kubernetes liveness probe | Application responding |
| `GET /up` | Rails default health check | Basic boot verification |

### Usage Examples

```bash
# Basic health check
curl http://localhost:3000/health

# Detailed health with all systems
curl http://localhost:3000/health/detailed

# Kubernetes probes
curl http://localhost:3000/ready
curl http://localhost:3000/live
```

## Structured Logging

### Log Format

Production logs use structured JSON format:

```json
{
  "timestamp": "2025-01-15T10:30:45Z",
  "level": "INFO",
  "pid": 12345,
  "source": "ApplicationController",
  "message": "User signed in",
  "environment": "production",
  "version": "career-companion",
  "request_id": "abc123",
  "user_id": 42
}
```

### Log Tags

Automatic request tagging includes:
- Request ID (for tracing)
- User ID (for user-specific debugging)
- IP Address (for security analysis)

### Key Log Events

#### AI Content Generation
```json
{
  "message": "AI content generation",
  "service": "AiContentService",
  "method": "generate_cover_letter",
  "duration_ms": 1500.25,
  "success": true,
  "application_id": 123
}
```

#### Database Performance
```json
{
  "message": "Slow query detected",
  "sql": "SELECT * FROM applications WHERE...",
  "duration_ms": 250.75,
  "connection_id": "abc123"
}
```

#### Background Jobs
```json
{
  "message": "Background job completed",
  "job_class": "CreateClJob",
  "job_id": "job_abc123",
  "queue": "default",
  "duration_ms": 2000.0
}
```

## Performance Monitoring

### Custom Instrumentation

The application instruments key operations using ActiveSupport::Notifications:

1. **AI Service Calls** (`ai_content_generation.application`)
2. **Database Queries** (`sql.active_record`) 
3. **Background Jobs** (`perform.active_job`)

### Metrics Collection

Key metrics tracked:
- Request duration and throughput
- AI generation success rates and latency
- Database query performance
- Background job queue depth
- Memory and CPU usage
- Error rates by endpoint

## Error Tracking

### Error Context

Errors are enriched with contextual information:

```ruby
# Example error logging
Rails.logger.error(
  message: "Application error",
  error_class: "ActiveRecord::RecordNotFound",
  error_message: "Couldn't find Application with id=123",
  user_id: current_user&.id,
  request_id: request.request_id,
  backtrace: error.backtrace.first(10)
)
```

### Error Categories

1. **User Errors**: Authentication, validation failures
2. **System Errors**: Database connectivity, external APIs
3. **AI Service Errors**: LLM API failures, timeouts
4. **Infrastructure Errors**: Memory, disk, network issues

## Integration Points

### Production Setup

For production deployments, integrate with:

#### 1. Log Aggregation
- **ELK Stack**: Elasticsearch, Logstash, Kibana
- **Grafana Loki**: Cost-effective log aggregation
- **AWS CloudWatch**: For AWS deployments
- **Datadog Logs**: Managed solution

#### 2. Metrics & Monitoring  
- **Prometheus + Grafana**: Open-source metrics
- **New Relic**: Full-stack monitoring
- **Datadog APM**: Application performance monitoring
- **Scout APM**: Rails-focused monitoring

#### 3. Error Tracking
- **Sentry**: Error tracking and alerting
- **Rollbar**: Error monitoring
- **Bugsnag**: Error reporting
- **Honeybadger**: Rails-specific error tracking

#### 4. Uptime Monitoring
- **Pingdom**: External uptime monitoring
- **UptimeRobot**: Free uptime checks
- **StatusPage**: Status page for users

### Container Orchestration

#### Kubernetes Configuration

```yaml
# Health check configuration
livenessProbe:
  httpGet:
    path: /live
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready  
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
```

#### Docker Compose

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Alerting Strategy

### Critical Alerts (Immediate Response)
- Application down (health checks failing)
- Database connectivity lost
- High error rates (>5% in 5 minutes)
- Memory usage >90%

### Warning Alerts (Monitor)
- Slow response times (>2s average)
- AI service failures (>10% in 10 minutes)
- Disk space >80%
- Background job queue backing up

### Info Alerts (Daily/Weekly)
- Performance trend reports
- Error pattern analysis  
- Usage statistics
- Capacity planning metrics

## Local Development

### Viewing Logs

```bash
# Follow application logs
tail -f log/development.log

# Filter for specific events
grep "AI content generation" log/development.log

# JSON formatted logs (if structured logging enabled)
tail -f log/development.log | jq '.'
```

### Health Check Testing

```bash
# Test all health endpoints
curl -s http://localhost:3000/health | jq '.'
curl -s http://localhost:3000/health/detailed | jq '.'
curl -s http://localhost:3000/ready | jq '.'
curl -s http://localhost:3000/live | jq '.'
```

### Performance Testing

```bash
# Generate AI content and observe logs
curl -X POST http://localhost:3000/applications/1/generate_cl \
  -d "prompt_cl=Generate a cover letter..."

# Monitor background job processing
bin/rails solid_queue:start

# Watch for slow queries in logs
grep "Slow query" log/development.log
```

## Troubleshooting

### Common Issues

1. **Health checks failing**
   - Check database connectivity
   - Verify disk space
   - Check application startup logs

2. **High response times**
   - Review slow query logs
   - Check AI service performance
   - Monitor memory usage

3. **Error spikes**
   - Review error logs with context
   - Check external service status
   - Verify recent deployments

### Debug Commands

```bash
# Check application health locally
bin/rails runner "puts HealthController.new.send(:perform_health_checks)"

# Verify database connectivity
bin/rails runner "ActiveRecord::Base.connection.execute('SELECT 1')"

# Test AI service (if configured)
bin/rails console
> app = Application.first
> service = AiContentService.new(app)  
> result = service.generate_cover_letter("test prompt")
```

## Security Considerations

### Log Security
- Never log sensitive data (passwords, API keys)
- Sanitize user input in logs
- Use log rotation to manage disk space
- Restrict access to production logs

### Health Check Security
- Health endpoints don't require authentication
- Limit information exposure in public health checks
- Use detailed health checks internally only
- Monitor health check endpoint usage