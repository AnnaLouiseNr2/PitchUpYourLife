class FakeJob < ApplicationJob
  queue_as :default

  def perform(*)
    Rails.logger.info "FakeJob started"
    sleep 3
    Rails.logger.info "FakeJob completed"
  end
end
