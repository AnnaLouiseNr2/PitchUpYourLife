require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Use rack_test for simpler, faster tests without browser
  driven_by :rack_test
  
  # Alternative browser setup for when selenium is needed
  # driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
