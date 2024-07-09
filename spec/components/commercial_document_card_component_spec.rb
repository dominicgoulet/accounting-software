# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommercialDocumentCardComponent do
  context 'has a valid constructor' do
    let(:component) { CommercialDocumentCardComponent.new(document: nil) }

    it { expect(component).not_to be_nil }
  end
end
