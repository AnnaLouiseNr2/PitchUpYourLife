require "test_helper"

class ApplicationPresenterTest < ActiveSupport::TestCase
  def setup
    @application = applications(:one)
    @presenter = ApplicationPresenter.new(@application)
  end

  test "formatted_created_date returns formatted date" do
    assert_match(/\w+ \d{1,2}, \d{4}/, @presenter.formatted_created_date)
  end

  test "display_name returns name or fallback" do
    assert_equal "TechCorp", @presenter.display_name
    
    @application.name = nil
    assert_equal "Unknown Company", @presenter.display_name
  end

  test "display_title returns title or fallback" do
    assert_equal "Software Engineer", @presenter.display_title
    
    @application.title = nil
    assert_equal "Unknown Position", @presenter.display_title
  end

  test "status_text returns human readable status" do
    @application.cl_status = "done"
    assert_equal "Complete", @presenter.status_text
    
    @application.cl_status = "processing"
    assert_equal "In Progress", @presenter.status_text
    
    @application.cl_status = "pending"
    assert_equal "Pending", @presenter.status_text
  end

  test "job_description_preview truncates long descriptions" do
    @application.job_d = "A" * 150
    preview = @presenter.job_description_preview(100)
    
    assert preview.length <= 104  # 100 + "..."
    assert preview.end_with?("...")
  end

  test "completion_percentage calculates correctly" do
    @application.cl_message = "Cover letter content"
    @application.video_message = "Video content"
    
    assert_equal 100, @presenter.completion_percentage
    
    @application.video_message = nil
    assert_equal 50, @presenter.completion_percentage
  end
end