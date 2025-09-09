# Presenter for Application views to encapsulate display logic and formatting
class ApplicationPresenter
  def initialize(application, view_context = nil)
    @application = application
    @view_context = view_context
  end

  # Format application creation date for display
  def formatted_created_date
    @application.created_at.strftime('%B %d, %Y')
  end

  # Get display name, fallback to "Unknown Company" if not set
  def display_name
    @application.name.presence || "Unknown Company"
  end

  # Get display title, fallback to "Unknown Position" if not set  
  def display_title
    @application.title.presence || "Unknown Position"
  end

  # Format application status for display with appropriate styling
  def status_badge_class
    case @application.cl_status
    when "done"
      "bg-success text-white"
    when "processing"
      "bg-warning text-dark"
    when "pending"
      "bg-secondary text-white"
    else
      "bg-danger text-white"
    end
  end

  # Get human readable status text
  def status_text
    case @application.cl_status
    when "done"
      "Complete"
    when "processing"
      "In Progress"
    when "pending"
      "Pending"
    else
      "Error"
    end
  end

  # Check if application has cover letter content
  def has_cover_letter?
    @application.cl_message.present?
  end

  # Check if application has video pitch content
  def has_video_pitch?
    @application.video_message.present?
  end

  # Get truncated job description for preview
  def job_description_preview(limit = 100)
    return "No job description" unless @application.job_d.present?
    
    if @application.job_d.length > limit
      "#{@application.job_d.truncate(limit)}..."
    else
      @application.job_d
    end
  end

  # Check if application is complete (has both cover letter and video pitch)
  def complete?
    has_cover_letter? && has_video_pitch?
  end

  # Get completion percentage
  def completion_percentage
    completed_items = 0
    completed_items += 1 if has_cover_letter?
    completed_items += 1 if has_video_pitch?
    
    (completed_items.to_f / 2 * 100).round
  end

  private

  # Delegate missing methods to the application object
  def method_missing(method_name, *args, &block)
    if @application.respond_to?(method_name)
      @application.send(method_name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @application.respond_to?(method_name) || super
  end
end