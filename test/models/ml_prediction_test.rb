require 'test_helper'

class MlPredictionTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @application = applications(:one)
    @ml_prediction = MlPrediction.new(
      user: @user,
      application: @application,
      prediction_type: 'success_probability',
      success_probability: 0.75,
      confidence_score: 0.8,
      model_version: '1.0.0',
      status: 'completed',
      processed_at: Time.current,
      processing_duration_ms: 1500
    )
  end

  test "should be valid with valid attributes" do
    assert @ml_prediction.valid?
  end

  test "should require prediction_type" do
    @ml_prediction.prediction_type = nil
    assert_not @ml_prediction.valid?
    assert_includes @ml_prediction.errors[:prediction_type], "can't be blank"
  end

  test "should validate prediction_type inclusion" do
    @ml_prediction.prediction_type = 'invalid_type'
    assert_not @ml_prediction.valid?
    assert_includes @ml_prediction.errors[:prediction_type], "is not included in the list"

    valid_types = %w[success_probability salary_range career_path]
    valid_types.each do |type|
      @ml_prediction.prediction_type = type
      assert @ml_prediction.valid?
    end
  end

  test "should require confidence_score" do
    @ml_prediction.confidence_score = nil
    assert_not @ml_prediction.valid?
    assert_includes @ml_prediction.errors[:confidence_score], "can't be blank"
  end

  test "should validate confidence_score range" do
    @ml_prediction.confidence_score = -0.1
    assert_not @ml_prediction.valid?

    @ml_prediction.confidence_score = 1.1
    assert_not @ml_prediction.valid?

    @ml_prediction.confidence_score = 0.5
    assert @ml_prediction.valid?
  end

  test "should validate status inclusion" do
    valid_statuses = %w[pending processing completed failed]
    valid_statuses.each do |status|
      @ml_prediction.status = status
      assert @ml_prediction.valid?
    end

    @ml_prediction.status = 'invalid_status'
    assert_not @ml_prediction.valid?
  end

  test "should have correct associations" do
    assert_equal @user, @ml_prediction.user
    assert_equal @application, @ml_prediction.application
  end

  test "completed? should return correct value" do
    @ml_prediction.status = 'completed'
    assert @ml_prediction.completed?

    @ml_prediction.status = 'pending'
    assert_not @ml_prediction.completed?
  end

  test "failed? should return correct value" do
    @ml_prediction.status = 'failed'
    assert @ml_prediction.failed?

    @ml_prediction.status = 'completed'
    assert_not @ml_prediction.failed?
  end

  test "high_confidence? should return correct value" do
    @ml_prediction.confidence_score = 0.9
    assert @ml_prediction.high_confidence?

    @ml_prediction.confidence_score = 0.7
    assert_not @ml_prediction.high_confidence?
  end

  test "processing_time_seconds should calculate correctly" do
    @ml_prediction.processing_duration_ms = 2500
    assert_equal 2.5, @ml_prediction.processing_time_seconds

    @ml_prediction.processing_duration_ms = nil
    assert_nil @ml_prediction.processing_time_seconds
  end

  test "confidence_level should return correct level" do
    @ml_prediction.confidence_score = 0.2
    assert_equal 'Low', @ml_prediction.confidence_level

    @ml_prediction.confidence_score = 0.5
    assert_equal 'Moderate', @ml_prediction.confidence_level

    @ml_prediction.confidence_score = 0.9
    assert_equal 'High', @ml_prediction.confidence_level
  end

  test "stale? should detect old predictions" do
    @ml_prediction.processed_at = 8.days.ago
    assert @ml_prediction.stale?

    @ml_prediction.processed_at = 5.days.ago
    assert_not @ml_prediction.stale?

    @ml_prediction.processed_at = nil
    assert_not @ml_prediction.stale?
  end

  test "formatted_results should format success probability correctly" do
    @ml_prediction.prediction_type = 'success_probability'
    @ml_prediction.success_probability = 0.756

    results = @ml_prediction.formatted_results

    assert_equal 75.6, results[:percentage]
    assert_equal '75.6%', results[:display]
    assert_equal 'High', results[:level]
    assert_equal 'High', results[:confidence]
  end

  test "formatted_results should format salary range correctly" do
    @ml_prediction.prediction_type = 'salary_range'
    @ml_prediction.salary_prediction = {
      'min' => 75000,
      'max' => 95000,
      'currency' => 'USD',
      'estimated' => 85000
    }

    results = @ml_prediction.formatted_results

    assert_equal 75000, results[:min]
    assert_equal 95000, results[:max]
    assert_equal 'USD', results[:currency]
    assert_equal '$75,000 - $95,000', results[:range_display]
    assert_equal '$85,000', results[:estimated_display]
  end

  test "formatted_results should format career paths correctly" do
    @ml_prediction.prediction_type = 'career_path'
    @ml_prediction.career_paths = [
      {
        'path_type' => 'vertical_progression',
        'title' => 'Senior Developer',
        'timeline' => '1-2 years',
        'probability' => 0.8,
        'requirements' => ['Leadership skills'],
        'salary_increase' => '20-30%'
      }
    ]

    results = @ml_prediction.formatted_results

    assert_equal 1, results[:count]
    assert_equal 'Senior Developer', results[:top_path][:title]
    assert_equal '80%', results[:top_path][:probability_display]
  end

  test "scopes should work correctly" do
    # Create test predictions
    completed_prediction = MlPrediction.create!(
      user: @user,
      application: @application,
      prediction_type: 'success_probability',
      confidence_score: 0.9,
      model_version: '1.0.0',
      status: 'completed'
    )

    failed_prediction = MlPrediction.create!(
      user: @user,
      application: @application,
      prediction_type: 'salary_range',
      confidence_score: 0.5,
      model_version: '1.0.0',
      status: 'failed'
    )

    assert_includes MlPrediction.completed, completed_prediction
    assert_not_includes MlPrediction.completed, failed_prediction

    assert_includes MlPrediction.failed, failed_prediction
    assert_not_includes MlPrediction.failed, completed_prediction

    assert_includes MlPrediction.high_confidence, completed_prediction
    assert_not_includes MlPrediction.high_confidence, failed_prediction

    assert_includes MlPrediction.by_type('success_probability'), completed_prediction
    assert_not_includes MlPrediction.by_type('success_probability'), failed_prediction
  end

  test "format_currency should handle different currencies" do
    prediction = @ml_prediction

    assert_equal '$75,000', prediction.send(:format_currency, 75000, 'USD')
    assert_equal '€75,000', prediction.send(:format_currency, 75000, 'EUR')
    assert_equal '£75,000', prediction.send(:format_currency, 75000, 'GBP')
    assert_equal '75,000 CAD', prediction.send(:format_currency, 75000, 'CAD')
    assert_equal 'N/A', prediction.send(:format_currency, nil)
  end
end