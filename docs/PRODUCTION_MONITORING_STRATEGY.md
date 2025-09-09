# Production Monitoring & Validation Strategy

## ML Service Performance Monitoring

### Success Probability Prediction Validation

```ruby
# Accuracy Tracking Service
class PredictionAccuracyTracker
  def track_success_prediction_accuracy
    # Real-time accuracy calculation
    recent_predictions = MlPrediction.success_probability
                                    .where(created_at: 30.days.ago..Time.current)
                                    .includes(:application)

    accuracy_metrics = calculate_prediction_accuracy(recent_predictions)
    
    # Store metrics for dashboards
    store_accuracy_metrics(accuracy_metrics)
    
    # Alert if accuracy drops below threshold
    alert_if_accuracy_degraded(accuracy_metrics)
    
    accuracy_metrics
  end

  private

  def calculate_prediction_accuracy(predictions)
    validated_predictions = predictions.select(&:outcome_validated?)
    
    return { error: 'insufficient_data' } if validated_predictions.count < 100

    {
      total_predictions: validated_predictions.count,
      correct_predictions: count_correct_predictions(validated_predictions),
      accuracy: calculate_overall_accuracy(validated_predictions),
      precision_by_confidence: calculate_precision_by_confidence_band(validated_predictions),
      calibration_score: calculate_calibration_accuracy(validated_predictions),
      false_positive_rate: calculate_false_positive_rate(validated_predictions),
      false_negative_rate: calculate_false_negative_rate(validated_predictions)
    }
  end

  def calculate_precision_by_confidence_band(predictions)
    confidence_bands = {
      high: predictions.select { |p| p.confidence_score > 0.8 },
      medium: predictions.select { |p| p.confidence_score.between?(0.5, 0.8) },
      low: predictions.select { |p| p.confidence_score < 0.5 }
    }

    confidence_bands.transform_values do |band_predictions|
      next 0 if band_predictions.empty?
      
      correct = band_predictions.count(&:prediction_correct?)
      correct.to_f / band_predictions.count
    end
  end
end
```

### Salary Prediction Validation

```ruby
class SalaryPredictionValidator
  SALARY_ACCURACY_THRESHOLDS = {
    excellent: 0.85,    # Within 15% of actual
    good: 0.70,         # Within 30% of actual  
    acceptable: 0.60,   # Within 40% of actual
    poor: 0.50          # More than 40% off
  }

  def validate_salary_predictions
    recent_salary_predictions = MlPrediction.salary_range
                                           .completed
                                           .where(created_at: 90.days.ago..Time.current)

    validation_results = analyze_salary_accuracy(recent_salary_predictions)
    
    # Real-time metrics
    {
      mean_absolute_percentage_error: calculate_mape(recent_salary_predictions),
      median_absolute_percentage_error: calculate_median_ape(recent_salary_predictions),
      accuracy_by_experience_level: group_by_experience_accuracy(recent_salary_predictions),
      accuracy_by_industry: group_by_industry_accuracy(recent_salary_predictions),
      range_accuracy: calculate_range_prediction_accuracy(recent_salary_predictions)
    }
  end

  private

  def calculate_mape(predictions)
    # Mean Absolute Percentage Error
    predictions_with_outcomes = predictions.select(&:actual_salary_reported?)
    
    return nil if predictions_with_outcomes.empty?

    total_percentage_error = predictions_with_outcomes.sum do |prediction|
      predicted = prediction.salary_prediction['estimated']
      actual = prediction.actual_salary_achieved
      
      ((predicted - actual).abs.to_f / actual * 100)
    end

    total_percentage_error / predictions_with_outcomes.count
  end

  def calculate_range_prediction_accuracy(predictions)
    predictions_in_range = predictions.count do |prediction|
      next false unless prediction.actual_salary_reported?
      
      min_predicted = prediction.salary_prediction['min']
      max_predicted = prediction.salary_prediction['max']
      actual = prediction.actual_salary_achieved
      
      actual.between?(min_predicted, max_predicted)
    end

    predictions_in_range.to_f / predictions.count
  end
end
```

## Service-Specific Monitoring Dashboards

### ML Prediction Service Dashboard

```ruby
class MlPredictionServiceMonitoring
  def generate_dashboard_metrics
    {
      # Performance Metrics
      prediction_generation_success_rate: calculate_generation_success_rate,
      average_prediction_processing_time: calculate_avg_processing_time,
      background_job_success_rate: calculate_job_success_rate,
      
      # Quality Metrics  
      prediction_accuracy_trends: calculate_accuracy_trends,
      confidence_score_distribution: analyze_confidence_distribution,
      feature_importance_stability: monitor_feature_importance,
      
      # Business Metrics
      user_engagement_with_predictions: calculate_user_engagement,
      prediction_influence_on_applications: measure_application_improvement,
      user_satisfaction_scores: collect_prediction_satisfaction,
      
      # System Health
      ai_service_response_times: monitor_ai_service_performance,
      database_query_performance: track_prediction_query_times,
      cache_hit_rates: monitor_prediction_cache_performance
    }
  end

  private

  def calculate_generation_success_rate
    recent_jobs = GenerateMlPredictionsJob.where(created_at: 24.hours.ago..Time.current)
    successful_jobs = recent_jobs.select(&:succeeded?)
    
    return 0 if recent_jobs.empty?
    successful_jobs.count.to_f / recent_jobs.count
  end

  def monitor_feature_importance
    # Track if feature importance is stable over time
    recent_predictions = MlPrediction.completed.last(1000)
    
    feature_importance_variance = recent_predictions.group_by_month(:created_at)
                                                   .map { |month, predictions| 
                                                     analyze_feature_usage(predictions) 
                                                   }
    
    calculate_feature_stability_score(feature_importance_variance)
  end
end
```

### LinkedIn Profile Analysis Monitoring

```ruby
class LinkedinAnalysisServiceMonitoring
  def generate_dashboard_metrics
    {
      # Processing Metrics
      pdf_analysis_success_rate: calculate_pdf_success_rate,
      average_analysis_processing_time: calculate_avg_analysis_time,
      profile_score_distribution: analyze_score_distribution,
      
      # Quality Metrics
      ai_parsing_success_rate: calculate_ai_parsing_success,
      recommendation_generation_success: calculate_recommendation_success,
      user_improvement_implementation_rate: track_improvement_adoption,
      
      # Business Impact
      profile_score_improvements: measure_score_improvements,
      user_satisfaction_with_analysis: collect_analysis_satisfaction,
      feature_usage_patterns: analyze_feature_usage_patterns
    }
  end

  def calculate_pdf_success_rate
    recent_analyses = LinkedinProfileAnalysisService.recent_analyses(24.hours)
    successful_analyses = recent_analyses.select(&:successful?)
    
    successful_analyses.count.to_f / recent_analyses.count
  end
end
```

## Alert Configuration

### Critical Alerts (Immediate Response)

```ruby
class ProductionAlertSystem
  CRITICAL_THRESHOLDS = {
    ml_prediction_success_rate: 0.95,
    salary_prediction_mape: 35.0,      # Mean Absolute Percentage Error
    background_job_failure_rate: 0.05,
    ai_service_response_time: 30.seconds,
    prediction_accuracy: 0.75
  }

  WARNING_THRESHOLDS = {
    user_satisfaction_score: 3.5,     # Out of 5
    feature_adoption_rate: 0.60,
    prediction_confidence_avg: 0.70,
    system_response_time: 2.seconds
  }

  def setup_monitoring_alerts
    # Critical Alerts - PagerDuty/Slack immediately
    setup_critical_alerts
    
    # Warning Alerts - Email/Slack during business hours  
    setup_warning_alerts
    
    # Trend Alerts - Weekly reports
    setup_trend_monitoring
  end

  private

  def setup_critical_alerts
    [
      {
        name: 'ML Prediction Service Down',
        condition: 'ml_prediction_success_rate < 0.95',
        notification: 'immediate',
        escalation: 'engineering_oncall'
      },
      {
        name: 'Salary Prediction Accuracy Degraded',
        condition: 'salary_prediction_mape > 35',
        notification: 'immediate',
        escalation: 'ml_team'
      },
      {
        name: 'Background Job Failures Spiking',
        condition: 'job_failure_rate > 0.05',
        notification: 'immediate',
        escalation: 'platform_team'
      }
    ].each { |alert| configure_alert(alert) }
  end

  def setup_warning_alerts
    [
      {
        name: 'User Satisfaction Declining',
        condition: 'user_satisfaction_score < 3.5',
        notification: 'business_hours',
        escalation: 'product_team'
      },
      {
        name: 'Prediction Confidence Low',
        condition: 'avg_confidence_score < 0.70',
        notification: 'business_hours',
        escalation: 'ml_team'
      }
    ].each { |alert| configure_alert(alert) }
  end
end
```

## Business Impact Metrics

### User Success Tracking

```ruby
class BusinessImpactTracker
  def track_prediction_business_value
    {
      # Application Success Improvement
      application_success_rate_improvement: measure_success_rate_improvement,
      user_application_quality_improvement: measure_quality_improvement,
      time_to_job_offer_reduction: measure_time_to_offer_reduction,
      
      # Salary Negotiation Impact
      salary_negotiation_success_rate: track_negotiation_success,
      average_salary_increase_achieved: calculate_avg_salary_increase,
      user_confidence_in_negotiations: survey_negotiation_confidence,
      
      # User Engagement
      feature_adoption_rate: calculate_feature_adoption,
      user_retention_with_predictions: measure_retention_improvement,
      referral_rate_from_prediction_users: track_referral_rates,
      
      # LinkedIn Profile Improvement
      profile_score_improvements: measure_profile_improvements,
      linkedin_engagement_increase: track_linkedin_metrics,
      interview_request_rate_improvement: measure_interview_improvements
    }
  end

  def measure_success_rate_improvement
    # Compare success rates before/after using predictions
    users_with_predictions = User.joins(:ml_predictions)
                                 .where(ml_predictions: { status: 'completed' })
                                 
    users_without_predictions = User.where.not(id: users_with_predictions.ids)
    
    {
      with_predictions: calculate_user_success_rate(users_with_predictions),
      without_predictions: calculate_user_success_rate(users_without_predictions),
      improvement: calculate_improvement_percentage
    }
  end
end
```

## Performance Monitoring Infrastructure

### Real-time Metrics Collection

```ruby
# config/initializers/metrics_collection.rb
class MetricsCollectionService
  def initialize
    @metrics_client = setup_metrics_client # DataDog, New Relic, etc.
  end

  def track_ml_prediction_metrics
    # Real-time metrics
    ActiveSupport::Notifications.subscribe('ml_prediction.application') do |name, started, finished, unique_id, data|
      processing_time = finished - started
      
      @metrics_client.increment('ml_predictions.generated', 
        tags: ["prediction_type:#{data[:prediction_type]}", "success:#{data[:success]}"])
      
      @metrics_client.histogram('ml_predictions.processing_time', processing_time,
        tags: ["prediction_type:#{data[:prediction_type]}"])
        
      @metrics_client.gauge('ml_predictions.confidence_score', data[:confidence_score],
        tags: ["prediction_type:#{data[:prediction_type]}"])
    end
    
    # LinkedIn analysis metrics
    ActiveSupport::Notifications.subscribe('linkedin_profile_analysis.user') do |name, started, finished, unique_id, data|
      @metrics_client.increment('linkedin_analysis.completed',
        tags: ["success:#{data[:success]}", "profile_sections:#{data[:profile_sections]}"])
    end
  end

  def setup_custom_dashboards
    # DataDog Dashboard Configuration
    dashboard_config = {
      title: "Career Companion ML Services",
      widgets: [
        prediction_success_rate_widget,
        prediction_accuracy_trends_widget,
        user_satisfaction_widget,
        system_performance_widget
      ]
    }
    
    create_monitoring_dashboard(dashboard_config)
  end
end
```

This comprehensive monitoring strategy ensures we can:

1. **Track prediction accuracy** in real-time with automated validation
2. **Monitor service health** with granular performance metrics
3. **Measure business impact** through user success and engagement tracking
4. **Respond quickly** to issues with tiered alerting system
5. **Continuously improve** through detailed analytics and user feedback

The monitoring infrastructure provides the foundation for confident scaling and continuous optimization of the ML prediction services.