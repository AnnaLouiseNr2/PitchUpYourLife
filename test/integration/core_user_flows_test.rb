require "test_helper"

class CoreUserFlowsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "user can sign up and create application" do
    # Sign up new user
    post user_registration_path, params: {
      user: {
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    
    # Follow redirects until we get to a successful response
    while response.redirect?
      follow_redirect!
    end
    assert response.successful?
    
    # Create application
    post applications_path, params: {
      application: {
        job_d: "Test job description for software engineer role"
      }
    }
    
    # Follow redirects until we get to a successful response
    while response.redirect?
      follow_redirect!
    end
    assert response.successful?
    assert Application.exists?(job_d: "Test job description for software engineer role")
  end

  test "signed in user can access application creation flow" do
    user = users(:one)
    sign_in user
    
    # Visit applications index
    get applications_path
    assert response.successful?
    
    # Visit new application form
    get new_application_path
    assert response.successful?
    
    # Create application
    assert_difference 'Application.count', 1 do
      post applications_path, params: {
        application: {
          job_d: "Senior Ruby Developer position at TestCorp"
        }
      }
    end
    
    application = Application.last
    assert_equal "Senior Ruby Developer position at TestCorp", application.job_d
    assert_equal user, application.user
  end

  test "trait page displays correctly" do
    user = users(:one)
    application = applications(:one)
    sign_in user
    
    # Access trait page (don't submit form to avoid CV extraction issues)
    get trait_application_path(application)
    assert response.successful?
    
    # Verify trait page loads with form elements
    assert_select "form"
  end

  test "application overview shows current status" do
    user = users(:one)
    application = applications(:one)
    sign_in user
    
    get overview_application_path(application)
    assert response.successful?
    
    # Should show overview page content
    assert_select "h1.page-title", text: "Review your Cover Letter and Video Pitch"
  end
end