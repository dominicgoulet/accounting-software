# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DropdownComponent do
  context 'has a valid constructor' do
    let(:component) { DropdownComponent.new(title: 'title', mode: 'dark') }

    it { expect(component).not_to be_nil }
  end
end
