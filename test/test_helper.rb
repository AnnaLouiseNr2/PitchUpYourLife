ENV["RAILS_ENV"] ||= "test"

# Start SimpleCov before loading application code
require 'simplecov'

SimpleCov.start 'rails' do
  # Set minimum coverage threshold
  minimum_coverage 30
  
  # Add custom groups
  add_group 'Services', 'app/services'
  add_group 'Presenters', 'app/presenters'
  add_group 'Jobs', 'app/jobs'
  
  # Skip coverage for files we don't need to test
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/lib/tasks'
  add_filter '/node_modules/'
  add_filter '/tmp/'
  add_filter '/vendor/'
  
  # Track coverage over time
  track_files '{app,lib}/**/*.rb'
  
  # Set output directory
  coverage_dir 'coverage'
end

require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
