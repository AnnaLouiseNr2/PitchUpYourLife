require 'test_helper'

class MlPredictionServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @application = applications(:one)
    @application.update!(
      cv_analysis: {
        'matching_score' => 75,
        'ats_keywords' => {
          'missing' => ['React', 'TypeScript'],
          'present' => ['JavaScript', 'HTML']
        },
        'content_quality' => { 'score' => 80 }
      },
      skills_gap_analysis: {
        'learning_priorities' => [
          { 'skill' => 'React', 'importance' => 'high' }
        ]
      }
    )
    @service = MlPredictionService.new(@user, @application)
  end

  test "should predict success probability successfully" do
    result = @service.predict_success_probability

    assert result[:success]
    assert result[:prediction].present?
    assert result[:success_probability].present?
    assert result[:confidence_score].present?
    assert_instance_of MlPrediction, result[:prediction]
    assert_equal 'success_probability', result[:prediction].prediction_type
  end

  test "should predict salary range successfully" do
    result = @service.predict_salary_range

    assert result[:success]
    assert result[:prediction].present?
    assert result[:salary_prediction].present?
    assert result[:salary_prediction]['min'].present?
    assert result[:salary_prediction]['max'].present?
    assert result[:salary_prediction]['currency'] == 'USD'
  end

  test "should predict career paths successfully" do
    result = @service.predict_career_paths

    assert result[:success]
    assert result[:prediction].present?
    assert result[:career_paths].present?
    assert result[:career_paths].is_a?(Array)
    assert result[:career_paths].first['path_type'].present?
  end

  test "should generate comprehensive predictions" do
    result = @service.generate_comprehensive_predictions

    assert result[:success]
    assert result[:predictions].keys.include?(:success_probability)
    assert result[:predictions].keys.include?(:salary_range)
    assert result[:predictions].keys.include?(:career_paths)
    assert result[:summary].present?
  end

  test "should extract features for prediction" do
    features = @service.send(:extract_features_for_prediction)

    assert features.keys.include?(:skills_match_percentage)
    assert features.keys.include?(:cv_quality_score)
    assert features.keys.include?(:matching_score)
    assert features.keys.include?(:missing_skills_count)
    
    # Check that values are reasonable
    assert features[:cv_quality_score] == 80
    assert features[:matching_score] == 75
    assert features[:missing_skills_count] == 2
  end

  test "should calculate success probability within valid range" do
    features = {
      skills_match_percentage: 80,
      cv_quality_score: 75,
      profile_completeness: 90,
      experience_relevance: 70,
      missing_skills_count: 2
    }

    probability = @service.send(:calculate_success_probability, features)

    assert probability >= 0.0
    assert probability <= 1.0
    assert probability > 0.5 # Should be above baseline for good features
  end

  test "should calculate salary prediction with reasonable values" do
    features = {
      experience_relevance: 70,
      skills_match_percentage: 80
    }

    salary_data = @service.send(:calculate_salary_prediction, features)

    assert salary_data['min'] > 0
    assert salary_data['max'] > salary_data['min']
    assert salary_data['currency'] == 'USD'
    assert salary_data['estimated'].present?
    
    # Check reasonable salary range
    assert salary_data['min'] >= 40000
    assert salary_data['max'] <= 200000
  end

  test "should calculate confidence score based on data quality" do
    good_features = {
      cv_quality_score: 85,
      skills_match_percentage: 75,
      profile_completeness: 90,
      coverletter_ready: true,
      video_ready: true,
      matching_score: 80
    }

    confidence = @service.send(:calculate_confidence_score, good_features)
    assert confidence >= 0.8

    poor_features = {
      cv_quality_score: 30,
      skills_match_percentage: 20
    }

    low_confidence = @service.send(:calculate_confidence_score, poor_features)
    assert low_confidence < 0.5
  end

  test "should generate career path predictions with required fields" do
    features = {
      skills_match_percentage: 75,
      experience_relevance: 65
    }

    paths = @service.send(:generate_career_path_predictions, features)

    assert paths.is_a?(Array)
    assert paths.count <= 3
    
    if paths.any?
      first_path = paths.first
      assert first_path['path_type'].present?
      assert first_path['title'].present?
      assert first_path['timeline'].present?
      assert first_path['probability'].present?
      assert first_path['requirements'].is_a?(Array)
    end
  end

  test "should create ml prediction record" do
    prediction_data = {
      prediction_type: 'success_probability',
      success_probability: 0.75,
      confidence_score: 0.8,
      input_features: { test: 'feature' }
    }

    assert_difference 'MlPrediction.count', 1 do
      prediction = @service.send(:create_ml_prediction, prediction_data)
      
      assert_equal @user, prediction.user
      assert_equal @application, prediction.application
      assert_equal 'success_probability', prediction.prediction_type
      assert_equal 0.75, prediction.success_probability
      assert_equal 'completed', prediction.status
    end
  end

  test "should calculate skills match percentage correctly" do
    skills_match = @service.send(:calculate_skills_match)
    
    # Based on setup: 2 present keywords, 2 missing = 50%
    assert_equal 50.0, skills_match
  end

  test "should handle missing analysis data gracefully" do
    @application.update!(cv_analysis: nil, skills_gap_analysis: nil)

    result = @service.predict_success_probability

    assert result[:success]
    assert result[:success_probability] <= 0.6 # Should be lower without analysis
  end

  test "should handle service errors gracefully" do
    # Simulate database error
    MlPrediction.stubs(:create!).raises(ActiveRecord::RecordInvalid.new(MlPrediction.new))

    result = @service.predict_success_probability

    assert_not result[:success]
    assert result[:error].present?
  end

  test "should generate predictions summary with insights" do
    results = {
      success_probability: { success: true, success_probability: 0.85 },
      salary_range: { success: true, salary_prediction: { 'min' => 75000, 'max' => 95000, 'currency' => 'USD' } },
      career_paths: { success: true, career_paths: [{ 'title' => 'Senior Developer' }] }
    }

    summary = @service.send(:generate_predictions_summary, results)

    assert summary['overall_score'] == 'excellent'
    assert summary['key_insights'].any? { |insight| insight.include?('High probability') }
    assert summary['key_insights'].any? { |insight| insight.include?('75000 - 95000 USD') }
  end
end