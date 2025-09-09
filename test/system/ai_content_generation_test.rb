require "application_system_test_case"

class AiContentGenerationTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @application = applications(:one)
    sign_in @user
  end

  test "user can access trait selection page" do
    visit trait_application_path(@application)
    
    assert_current_path trait_application_path(@application)
    # Should show trait selection form - check for form element
    assert page.has_css?("form")
  end

  test "user can access application overview page" do
    visit overview_application_path(@application)
    
    assert_current_path overview_application_path(@application)
    # Should show overview page
    assert_text "Review your Cover Letter and Video Pitch"
  end
end