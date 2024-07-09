# frozen_string_literal: true

class SelectComponent < ViewComponent::Base
  renders_one :toggle
  renders_one :links

  def initialize(title:)
    super
    @title = title
  end
end
