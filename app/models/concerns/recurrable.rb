# frozen_string_literal: true

module Recurrable
  extend ActiveSupport::Concern

  included do
    # Associations
    has_one :recurring_event, as: :recurrable
  end

  def setup_recurring_event!(enabled, recurring_event_params)
    if enabled
      if recurring_event.present?
        # update
        recurring_event.update(recurring_event_params)
      else
        # create
        self.recurring_event = organization.recurring_events.create(recurring_event_params)
      end
    elsif recurring_event.present?
      recurring_event.destroy
    end
  end
end
