# Presenter for Job Application objects
#
# Encapsulates view logic for displaying application data,
# status information, and related content generation states.
# Reduces complexity in views and controllers.
#
# Usage:
#   presenter = JobApplicationPresenter.new(application, view)
#   presenter.status_display
#   presenter.formatted_traits

class JobApplicationPresenter < ApplicationPresenter
  # Display formatted application status
  def status_display
    case object.cl_status&.downcase
    when "done"
      content_tag(:span, "Cover Letter Ready", class: "badge bg-success")
    when "processing" 
      content_tag(:span, "Generating...", class: "badge bg-warning")
    when /error/
      content_tag(:span, "Error", class: "badge bg-danger")
    else
      content_tag(:span, "Pending", class: "badge bg-secondary")
    end
  end

  # Display video generation status
  def video_status_display
    case object.video_status&.downcase
    when "done"
      content_tag(:span, "Video Script Ready", class: "badge bg-success")
    when "processing"
      content_tag(:span, "Generating...", class: "badge bg-warning")
    when /error/
      content_tag(:span, "Error", class: "badge bg-danger") 
    else
      content_tag(:span, "Pending", class: "badge bg-secondary")
    end
  end

  # Format traits for display
  def formatted_traits
    return "No traits selected" unless traits.present?
    
    [
      trait_item("Tone", traits.first),
      trait_item("Strength", traits.second), 
      trait_item("Experience", traits.third),
      trait_item("Motivation", traits.fourth)
    ].compact.join(" • ").html_safe
  end

  # Truncated job description for cards/lists
  def job_description_summary
    truncate_text(object.job_d, length: 150)
  end

  # Company and title display
  def company_and_title
    parts = [object.name, object.title].compact
    return "Untitled Application" if parts.empty?
    parts.join(" - ")
  end

  # Progress indicator for application completion
  def completion_progress
    completed_steps = 0
    total_steps = 4

    completed_steps += 1 if object.job_d.present?
    completed_steps += 1 if object.cv.attached?
    completed_steps += 1 if object.cl_status == "done"
    completed_steps += 1 if object.video_status == "done"

    {
      percentage: (completed_steps.to_f / total_steps * 100).round,
      completed: completed_steps,
      total: total_steps
    }
  end

  # Check if application is ready for final submission
  def ready_for_submission?
    object.cl_status == "done" && 
    object.video_status == "done" &&
    object.job_d.present? &&
    object.cv.attached?
  end

  private

  def traits
    @traits ||= object.traits.last
  end

  def trait_item(label, value)
    return nil unless value.present?
    content_tag(:span, "#{label}: #{value}", class: "trait-item")
  end

  def content_tag(tag, content = nil, options = {}, &block)
    h.content_tag(tag, content, options, &block)
  end
end