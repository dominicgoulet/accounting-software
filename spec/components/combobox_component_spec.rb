# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComboboxComponent do
  context 'has a valid constructor' do
    let(:component) { ComboboxComponent.new(form: nil, field: nil, kind: nil, options: [], initial_value: nil) }

    it { expect(component).not_to be_nil }
  end
end
