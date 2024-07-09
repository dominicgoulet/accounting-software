# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Journalable do
  context 'has a valid factory' do
    let(:journalable) { FactoryBot.build(:invoice) }

    it { expect(journalable).to be_valid }
  end

  context 'callbacks' do
    let(:journalable) { FactoryBot.build(:invoice) }

    it { expect(journalable).to callback(:update_journal_entry).after(:save) }
    it { expect(journalable).to callback(:destroy_journal_entry).before(:destroy) }
  end
end
