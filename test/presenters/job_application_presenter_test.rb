require "test_helper"

class JobApplicationPresenterTest < ActiveSupport::TestCase
  def setup
    # Create a mock application
    @application = OpenStruct.new(
      id: 1,
      job_d: "Software Engineer position at TechCorp",
      name: "TechCorp", 
      title: "Software Engineer",
      cl_status: "done",
      video_status: "processing"
    )
    
    # Mock traits
    @traits = OpenStruct.new(
      first: "Professional",
      second: "Problem Solving", 
      third: "Mid-level",
      fourth: "Growth"
    )
    @application.define_singleton_method(:traits) { OpenStruct.new(last: @traits) }
    @application.define_singleton_method(:cv) { OpenStruct.new(attached?: true) }
    
    # Mock view context
    @view_context = Object.new
    @view_context.define_singleton_method(:content_tag) { |tag, content, options| "<#{tag} class='#{options[:class]}'>#{content}</#{tag}>" }
    @view_context.define_singleton_method(:truncate) { |text, length:| text.length > length ? "#{text[0...length]}..." : text }
    
    @presenter = JobApplicationPresenter.new(@application, @view_context)
  end

  test "should initialize with application and view context" do
    assert_equal @application, @presenter.object
    assert_equal @view_context, @presenter.view_context
  end

  test "should delegate methods to wrapped object" do
    assert_equal "TechCorp", @presenter.name
    assert_equal "Software Engineer", @presenter.title
    assert_equal "done", @presenter.cl_status
  end

  test "company_and_title should format name and title" do
    assert_equal "TechCorp - Software Engineer", @presenter.company_and_title
  end

  test "company_and_title should handle missing data" do
    @application.name = nil
    @application.title = nil
    assert_equal "Untitled Application", @presenter.company_and_title
  end

  test "job_description_summary should truncate long descriptions" do
    long_description = "A" * 200
    @application.job_d = long_description
    summary = @presenter.job_description_summary
    assert summary.length <= 153 # 150 + "..."
  end

  test "completion_progress should calculate correctly" do
    progress = @presenter.completion_progress
    
    assert_equal 3, progress[:completed] # job_d, cv, cl_status done
    assert_equal 4, progress[:total]
    assert_equal 75, progress[:percentage]
  end

  test "ready_for_submission should return false when incomplete" do
    refute @presenter.ready_for_submission?
    
    @application.video_status = "done"
    assert @presenter.ready_for_submission?
  end
end