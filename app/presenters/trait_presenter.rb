# Presenter for Trait display logic to handle conditional rendering and formatting
class TraitPresenter
  def initialize(trait_array)
    @trait = trait_array || []
  end

  # Get tone with fallback
  def tone
    display_value(@trait[0], "Not selected")
  end

  # Get professional strength with "Other" handling
  def professional_strength
    value = @trait[1]
    return "Not selected" if value.blank?
    
    if value == "Other"
      "Not specified"
    else
      value
    end
  end

  # Get experience level with fallback
  def experience_level
    display_value(@trait[2], "Not selected")
  end

  # Get career motivation with "Other" handling
  def career_motivation
    value = @trait[3]
    return "Not selected" if value.blank?
    
    if value == "Other"
      "Not specified"
    else
      value
    end
  end

  # Check if all traits are selected
  def complete?
    [@trait[0], @trait[1], @trait[2], @trait[3]].all?(&:present?)
  end

  # Get completion percentage
  def completion_percentage
    selected_count = [@trait[0], @trait[1], @trait[2], @trait[3]].count(&:present?)
    (selected_count.to_f / 4 * 100).round
  end

  # Get trait data for structured display
  def trait_data
    [
      { label: 'Tone', value: tone },
      { label: 'Professional Strength', value: professional_strength },
      { label: 'Experience Level', value: experience_level },
      { label: 'Career Motivation', value: career_motivation }
    ]
  end

  # Check if any traits are selected
  def any_selected?
    [@trait[0], @trait[1], @trait[2], @trait[3]].any?(&:present?)
  end

  # Get summary text for traits
  def summary_text
    return "No traits selected" unless any_selected?
    
    if complete?
      "All traits selected"
    else
      selected_count = [@trait[0], @trait[1], @trait[2], @trait[3]].count(&:present?)
      "#{selected_count} of 4 traits selected"
    end
  end

  private

  def display_value(value, fallback)
    value.present? ? value : fallback
  end
end