require 'test_helper'

class GenerateMlPredictionsJobTest < ActiveJob::TestCase
  def setup
    @user = users(:one)
    @application = applications(:one)
    @application.update!(
      cv_analysis: { 'matching_score' => 75 },
      skills_gap_analysis: { 'learning_priorities' => [] }
    )
  end

  test "should generate ML predictions successfully" do
    # Mock the ML service to return successful results
    mock_service = mock('ml_service')
    mock_results = {
      success: true,
      predictions: {
        success_probability: { success: true },
        salary_range: { success: true },
        career_paths: { success: true }
      },
      summary: { 'overall_score' => 'good' }
    }
    
    mock_service.stubs(:generate_comprehensive_predictions).returns(mock_results)
    MlPredictionService.stubs(:new).with(@user, @application).returns(mock_service)

    assert_no_difference 'MlPrediction.count' do # Mock service doesn't create real records
      perform_enqueued_jobs do
        GenerateMlPredictionsJob.perform_later(@application.id, @user.id)
      end
    end

    # Check that no errors were raised
    assert true
  end

  test "should handle ML service failures gracefully" do
    # Mock the ML service to return failed results
    mock_service = mock('ml_service')
    mock_results = {
      success: false,
      predictions: {
        success_probability: { success: false, error: 'Service unavailable' },
        salary_range: { success: true },
        career_paths: { success: true }
      }
    }
    
    mock_service.stubs(:generate_comprehensive_predictions).returns(mock_results)
    MlPredictionService.stubs(:new).with(@user, @application).returns(mock_service)

    assert_raises StandardError do
      perform_enqueued_jobs do
        GenerateMlPredictionsJob.perform_later(@application.id, @user.id)
      end
    end
  end

  test "should handle record not found errors" do
    invalid_application_id = 99999
    invalid_user_id = 99999

    assert_raises ActiveRecord::RecordNotFound do
      perform_enqueued_jobs do
        GenerateMlPredictionsJob.perform_later(invalid_application_id, invalid_user_id)
      end
    end
  end

  test "should retry on standard errors" do
    # Mock to raise an error on first call, succeed on second
    mock_service = mock('ml_service')
    mock_service.stubs(:generate_comprehensive_predictions)
               .raises(StandardError.new('Temporary failure'))
               .then.returns({
                 success: true,
                 predictions: {
                   success_probability: { success: true },
                   salary_range: { success: true },
                   career_paths: { success: true }
                 }
               })
    
    MlPredictionService.stubs(:new).returns(mock_service)

    # The job should retry and eventually succeed
    assert_no_difference 'MlPrediction.count' do
      perform_enqueued_jobs do
        GenerateMlPredictionsJob.perform_later(@application.id, @user.id)
      end
    end
  end

  test "should be queued with high priority" do
    GenerateMlPredictionsJob.perform_later(@application.id, @user.id)

    assert_equal 'high', GenerateMlPredictionsJob.new.queue_name
  end

  test "should log success information" do
    # Mock successful service call
    mock_service = mock('ml_service')
    mock_results = {
      success: true,
      predictions: {
        success_probability: { success: true },
        salary_range: { success: true },
        career_paths: { success: true }
      }
    }
    
    mock_service.stubs(:generate_comprehensive_predictions).returns(mock_results)
    MlPredictionService.stubs(:new).returns(mock_service)

    # Check that Rails.logger.info is called with success message
    Rails.logger.expects(:info).with(
      message: "Starting ML predictions generation",
      application_id: @application.id,
      user_id: @user.id
    )

    Rails.logger.expects(:info).with(
      message: "ML predictions generated successfully",
      application_id: @application.id,
      user_id: @user.id,
      predictions_generated: 3
    )

    perform_enqueued_jobs do
      GenerateMlPredictionsJob.perform_later(@application.id, @user.id)
    end
  end

  test "should log error information on failure" do
    # Mock failed service call
    mock_service = mock('ml_service')
    mock_results = {
      success: false,
      predictions: {
        success_probability: { success: false, error: 'AI service timeout' },
        salary_range: { success: true },
        career_paths: { success: false, error: 'Invalid data' }
      }
    }
    
    mock_service.stubs(:generate_comprehensive_predictions).returns(mock_results)
    MlPredictionService.stubs(:new).returns(mock_service)

    Rails.logger.expects(:error).with(
      message: "ML predictions generation failed",
      application_id: @application.id,
      user_id: @user.id,
      failed_predictions: [:success_probability, :career_paths],
      errors: ['AI service timeout', 'Invalid data']
    )

    assert_raises StandardError do
      perform_enqueued_jobs do
        GenerateMlPredictionsJob.perform_later(@application.id, @user.id)
      end
    end
  end

  test "should initialize ML service with correct parameters" do
    mock_service = mock('ml_service')
    mock_results = {
      success: true,
      predictions: {
        success_probability: { success: true },
        salary_range: { success: true },
        career_paths: { success: true }
      }
    }
    
    # Verify that MlPredictionService is initialized with correct user and application
    MlPredictionService.expects(:new).with(@user, @application).returns(mock_service)
    mock_service.stubs(:generate_comprehensive_predictions).returns(mock_results)

    perform_enqueued_jobs do
      GenerateMlPredictionsJob.perform_later(@application.id, @user.id)
    end
  end
end