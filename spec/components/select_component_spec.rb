# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelectComponent do
  context 'has a valid constructor' do
    let(:component) { SelectComponent.new(title: 'title') }

    it { expect(component).not_to be_nil }
  end
end
