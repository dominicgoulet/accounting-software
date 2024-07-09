# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SwapComponent do
  context 'has a valid constructor' do
    let(:component) { SwapComponent.new(name: nil, field_name: nil, checked: false, data: nil) }

    it { expect(component).not_to be_nil }
  end
end
