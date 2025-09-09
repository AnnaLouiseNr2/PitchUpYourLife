require "test_helper"

class DashboardPresenterTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @applications = [@applications = applications(:one), applications(:two)]
    @presenter = DashboardPresenter.new(@user, @applications)
  end

  test "user_display_name formats email correctly" do
    @user.email = "john.doe@example.com"
    assert_equal "John Doe", @presenter.user_display_name
    
    @user.email = "simple@test.com"
    assert_equal "Simple", @presenter.user_display_name
  end

  test "member_since_date formats date correctly" do
    assert_match(/\w+ \d{4}/, @presenter.member_since_date)
  end

  test "total_applications_count returns correct count" do
    assert_equal 2, @presenter.total_applications_count
  end

  test "has_applications returns boolean correctly" do
    assert @presenter.has_applications?
    
    empty_presenter = DashboardPresenter.new(@user, [])
    refute empty_presenter.has_applications?
  end

  test "recent_applications returns ApplicationPresenter objects" do
    recent = @presenter.recent_applications(1)
    
    assert_equal 1, recent.length
    assert_instance_of ApplicationPresenter, recent.first
  end

  test "application_stats returns formatted stats" do
    stats = @presenter.application_stats
    
    assert_instance_of Array, stats
    assert stats.length > 0
    assert stats.first.has_key?(:label)
    assert stats.first.has_key?(:count)
    assert stats.first.has_key?(:badge_class)
  end

  test "welcome_message varies based on user activity" do
    # Test existing user with applications - should show welcome back message
    message = @presenter.welcome_message
    # The method will show "Welcome back!" for users with applications
    assert message.include?("Welcome back!") || message.include?("applications")
    
    # Test user without applications - should show different message
    empty_presenter = DashboardPresenter.new(@user, [])
    message = empty_presenter.welcome_message
    assert message.include?("Ready to land your dream job?")
  end
end