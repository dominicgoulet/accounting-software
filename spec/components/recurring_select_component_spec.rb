# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecurringSelectComponent do
  context 'has a valid constructor' do
    let(:component) { RecurringSelectComponent.new(recurring_event: nil) }

    it { expect(component).not_to be_nil }
  end
end
