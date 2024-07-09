# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SalesTaxPickerComponent do
  context 'has a valid constructor' do
    let(:component) { SalesTaxPickerComponent.new(kind: nil, form: nil, field: nil, organization: nil) }

    it { expect(component).not_to be_nil }
  end
end
