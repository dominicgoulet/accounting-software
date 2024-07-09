# frozen_string_literal: true

class SwapComponent < ViewComponent::Base
  def initialize(name:, field_name:, checked:, data:)
    super
    @name = name
    @field_name = field_name
    @checked = checked
    @data = data || {}
  end
end
