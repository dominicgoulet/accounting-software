# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auditable do
  context 'has a valid factory' do
    let(:auditable) { FactoryBot.build(:invoice) }

    it { expect(auditable).to be_valid }
  end

  context 'associations' do
    let(:auditable) { FactoryBot.build(:invoice) }

    it { expect(auditable).to have_many(:audit_events) }
  end
end
