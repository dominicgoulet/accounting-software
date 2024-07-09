# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  include Turbo::FramesHelper

  def initialize(wide: false)
    super
    @wide = wide
  end
end
