# frozen_string_literal: true

class SectionMenuComponent < ViewComponent::Base
  def initialize(items:, context:)
    super
    @items = items
    @context = context
  end

  def active?(path, controller)
    @context[:controller].split('/').include?(controller) || request.path == path
  end
end
