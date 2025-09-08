# Base presenter class for application-wide presentation logic
#
# Provides common methods and functionality for all presenters.
# Follows the Presenter pattern to encapsulate view logic and keep
# controllers and views clean.
#
# Usage:
#   presenter = ApplicationPresenter.new(object, view_context)
#   presenter.formatted_date(date)

class ApplicationPresenter
  attr_reader :object, :view_context

  def initialize(object, view_context)
    @object = object
    @view_context = view_context
  end

  # Delegate missing methods to the wrapped object
  def method_missing(method, *args, &block)
    if object.respond_to?(method)
      object.public_send(method, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private = false)
    object.respond_to?(method, include_private) || super
  end

  # Common presentation helpers
  def formatted_date(date, format: :short)
    return "N/A" unless date
    
    case format
    when :short
      view_context.l(date, format: :short)
    when :long  
      view_context.l(date, format: :long)
    else
      date.strftime(format)
    end
  end

  def status_badge_class(status)
    case status.to_s.downcase
    when "done", "completed", "success"
      "badge-success"
    when "processing", "in_progress"
      "badge-warning" 
    when "error", "failed"
      "badge-danger"
    else
      "badge-secondary"
    end
  end

  def truncate_text(text, length: 100)
    return "" unless text
    view_context.truncate(text, length: length)
  end

  private

  # Helper method for subclasses to access Rails helpers
  def h
    view_context
  end
end