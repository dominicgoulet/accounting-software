# frozen_string_literal: true

class DropdownComponent < ViewComponent::Base
  renders_one :toggle
  renders_one :links

  def initialize(title:, mode:)
    super
    @title = title
    @mode = mode
  end

  def css_classes
    {
      dark: 'flex max-w-xs items-center rounded-full bg-gray-800 text-sm focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800',
      light: 'flex items-center rounded-full bg-white text-gray-400 hover:text-gray-600 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-gray-100'
    }[@mode.to_sym]
  end
end
