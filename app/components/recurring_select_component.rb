# frozen_string_literal: true

class RecurringSelectComponent < ViewComponent::Base
  def initialize(recurring_event:)
    super
    @recurring_event = recurring_event
  end
end
