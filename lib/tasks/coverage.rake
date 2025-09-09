namespace :test do
  desc "Run tests with coverage report"
  task :coverage do
    puts "🧪 Running tests with SimpleCov coverage reporting..."
    
    # Set environment to test
    ENV['RAILS_ENV'] = 'test'
    
    # Run the test suite
    system("bin/rails test")
    
    puts "\n📊 Coverage report generated at: coverage/index.html"
    puts "   Open in browser: file://#{Rails.root}/coverage/index.html"
    
    # Check coverage threshold
    if File.exist?('coverage/.last_run.json')
      require 'json'
      last_run = JSON.parse(File.read('coverage/.last_run.json'))
      coverage = last_run.dig('result', 'line')
      
      if coverage
        puts "   Line Coverage: #{coverage.round(2)}%"
        if coverage < 30
          puts "   ⚠️  Coverage below minimum threshold of 30%"
          exit(1)
        else
          puts "   ✅ Coverage meets minimum threshold"
        end
      end
    end
  end
  
  desc "Open coverage report in browser"
  task :coverage_open do
    coverage_file = Rails.root.join('coverage', 'index.html')
    if coverage_file.exist?
      puts "📖 Opening coverage report..."
      system("open #{coverage_file}") if RUBY_PLATFORM.include?('darwin')
      system("xdg-open #{coverage_file}") if RUBY_PLATFORM.include?('linux')
    else
      puts "❌ No coverage report found. Run 'rake test:coverage' first."
    end
  end
end

desc "Run tests with coverage (alias for test:coverage)"
task coverage: 'test:coverage'