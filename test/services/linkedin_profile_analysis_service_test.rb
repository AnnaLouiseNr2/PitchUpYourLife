require 'test_helper'

class LinkedinProfileAnalysisServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @service = LinkedinProfileAnalysisService.new(@user)
    @sample_pdf = fixture_file_upload('linkedin_profile.pdf', 'application/pdf')
    @sample_analysis = {
      'basic_info' => {
        'name' => 'John Doe',
        'headline' => 'Software Engineer at Tech Corp',
        'summary' => 'Experienced software engineer with 5 years of experience'
      },
      'experience' => [
        {
          'title' => 'Software Engineer',
          'company' => 'Tech Corp',
          'duration' => '2 years',
          'description' => 'Developed web applications'
        }
      ],
      'skills' => ['JavaScript', 'React', 'Node.js'],
      'education' => [
        {
          'degree' => 'Computer Science',
          'institution' => 'University',
          'year' => '2019'
        }
      ]
    }
  end

  test "should analyze profile pdf successfully" do
    # Mock PDF text extraction
    @service.stubs(:extract_pdf_text).returns("John Doe Software Engineer...")
    
    # Mock AI response
    mock_ai_response = double('ai_response', content: @sample_analysis.to_json)
    mock_chat = double('chat')
    mock_chat.stubs(:with_instructions).returns(mock_chat)
    mock_chat.stubs(:ask).returns(mock_ai_response)
    RubyLLM.stubs(:chat).returns(mock_chat)

    result = @service.analyze_profile_pdf(@sample_pdf)

    assert result[:success]
    assert_equal 'John Doe', result[:analysis]['basic_info']['name']
    assert_includes result[:analysis]['skills'], 'JavaScript'
  end

  test "should handle pdf text extraction failure gracefully" do
    @service.stubs(:extract_pdf_text).raises(StandardError.new("PDF read error"))

    result = @service.analyze_profile_pdf(@sample_pdf)

    assert_not result[:success]
    assert_includes result[:error], "PDF read error"
  end

  test "should calculate profile score correctly" do
    score = @service.calculate_profile_score(@sample_analysis)

    # Should get points for: headline(15) + summary(10) + experience(15) + 
    # education(10) + skills(10) + good summary length(10) + skills count(10)
    expected_score = 80
    assert_equal expected_score, score
  end

  test "should calculate profile score for empty profile" do
    empty_analysis = {
      'basic_info' => {},
      'experience' => [],
      'skills' => []
    }

    score = @service.calculate_profile_score(empty_analysis)
    assert_equal 0, score
  end

  test "should get profile recommendations successfully" do
    # Mock AI response for recommendations
    recommendations = {
      'priority_improvements' => [
        {
          'section' => 'Summary',
          'recommendation' => 'Add more keywords',
          'priority' => 'high'
        }
      ],
      'keyword_suggestions' => [],
      'content_improvements' => {}
    }

    mock_ai_response = double('ai_response', content: recommendations.to_json)
    mock_chat = double('chat')
    mock_chat.stubs(:with_instructions).returns(mock_chat)
    mock_chat.stubs(:ask).returns(mock_ai_response)
    RubyLLM.stubs(:chat).returns(mock_chat)

    result = @service.get_profile_recommendations(@sample_analysis)

    assert result[:success]
    assert_equal 1, result[:recommendations]['priority_improvements'].count
  end

  test "should handle AI parsing errors gracefully" do
    # Mock invalid JSON response
    mock_ai_response = double('ai_response', content: "Invalid JSON response")
    mock_chat = double('chat')
    mock_chat.stubs(:with_instructions).returns(mock_chat)
    mock_chat.stubs(:ask).returns(mock_ai_response)
    RubyLLM.stubs(:chat).returns(mock_chat)

    result = @service.analyze_profile_pdf(@sample_pdf)

    # Should still succeed with fallback structure
    assert result[:success]
    assert result[:analysis]['basic_info'].present?
    assert result[:analysis]['analysis']['profile_strength'].include?('parsing error')
  end

  test "should build proper analysis prompt" do
    prompt = @service.send(:build_analysis_prompt)

    assert_includes prompt, 'LinkedIn profile optimization expert'
    assert_includes prompt, '"basic_info"'
    assert_includes prompt, '"experience"'
    assert_includes prompt, '"skills"'
    assert_includes prompt, 'JSON structure'
  end

  private

  def fixture_file_upload(file, mime_type = nil, binary = false)
    Rack::Test::UploadedFile.new(
      Rails.root.join('test', 'fixtures', 'files', file),
      mime_type,
      binary
    )
  end
end