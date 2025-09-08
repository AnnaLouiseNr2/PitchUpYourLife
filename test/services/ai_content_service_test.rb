require "test_helper"

class AiContentServiceTest < ActiveSupport::TestCase
  def setup
    # Create a mock application since fixtures might not exist
    @application = OpenStruct.new(id: 1, job_d: "Test job description")
    @service = AiContentService.new(@application, cv_text: "Mock CV content")
  end

  test "should initialize with application and cv_text" do
    assert_equal @application, @service.application
    assert_equal "Mock CV content", @service.cv_text
  end

  test "should respond to service methods" do
    assert_respond_to @service, :generate_cover_letter
    assert_respond_to @service, :generate_pitch_script
    assert_respond_to @service, :extract_company_name
    assert_respond_to @service, :extract_job_title
  end
end