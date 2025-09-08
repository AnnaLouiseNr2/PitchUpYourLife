# Concern for adding presenter functionality to controllers
#
# Provides helper methods for creating and using presenters
# in controllers and making them available to views.

module Presentable
  extend ActiveSupport::Concern

  private

  # Create a presenter for an object
  def present(object, presenter_class = nil)
    presenter_class ||= "#{object.class.name}Presenter".constantize
    presenter_class.new(object, view_context)
  end

  # Create a job application presenter  
  def present_application(application)
    JobApplicationPresenter.new(application, view_context)
  end
end