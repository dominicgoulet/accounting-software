# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SectionMenuComponent do
  context 'has a valid constructor' do
    let(:component) { SectionMenuComponent.new(items: nil, context: nil) }

    it { expect(component).not_to be_nil }
  end
end
