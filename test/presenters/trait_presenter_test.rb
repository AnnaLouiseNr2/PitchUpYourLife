require "test_helper"

class TraitPresenterTest < ActiveSupport::TestCase
  def setup
    @trait_data = ["Professional", "Problem Solving", "Mid-level", "Growth"]
    @presenter = TraitPresenter.new(@trait_data)
  end

  test "tone returns correct value with fallback" do
    assert_equal "Professional", @presenter.tone
    
    empty_presenter = TraitPresenter.new([])
    assert_equal "Not selected", empty_presenter.tone
  end

  test "professional_strength handles Other value correctly" do
    assert_equal "Problem Solving", @presenter.professional_strength
    
    other_presenter = TraitPresenter.new([nil, "Other"])
    assert_equal "Not specified", other_presenter.professional_strength
  end

  test "career_motivation handles Other value correctly" do
    assert_equal "Growth", @presenter.career_motivation
    
    other_presenter = TraitPresenter.new([nil, nil, nil, "Other"])
    assert_equal "Not specified", other_presenter.career_motivation
  end

  test "complete returns true when all traits selected" do
    assert @presenter.complete?
    
    incomplete_presenter = TraitPresenter.new(["Professional", nil, "Mid-level", "Growth"])
    refute incomplete_presenter.complete?
  end

  test "completion_percentage calculates correctly" do
    assert_equal 100, @presenter.completion_percentage
    
    half_presenter = TraitPresenter.new(["Professional", "Problem Solving", nil, nil])
    assert_equal 50, half_presenter.completion_percentage
  end

  test "trait_data returns structured array" do
    data = @presenter.trait_data
    
    assert_equal 4, data.length
    assert_equal "Tone", data.first[:label]
    assert_equal "Professional", data.first[:value]
  end

  test "any_selected returns correct boolean" do
    assert @presenter.any_selected?
    
    empty_presenter = TraitPresenter.new([])
    refute empty_presenter.any_selected?
  end

  test "summary_text provides correct summary" do
    assert_equal "All traits selected", @presenter.summary_text
    
    partial_presenter = TraitPresenter.new(["Professional", nil, "Mid-level", nil])
    assert_equal "2 of 4 traits selected", partial_presenter.summary_text
    
    empty_presenter = TraitPresenter.new([])
    assert_equal "No traits selected", empty_presenter.summary_text
  end
end