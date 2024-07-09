# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entry_lines
#
#  id               :uuid             not null, primary key
#  credit           :decimal(, )
#  debit            :decimal(, )
#  description      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :uuid
#  business_unit_id :uuid
#  contact_id       :uuid
#  journal_entry_id :uuid
#
require 'rails_helper'

RSpec.describe JournalEntryLine do
  context 'has a valid factory' do
    let(:journal_entry_line) { FactoryBot.build(:journal_entry_line) }

    it { expect(journal_entry_line).to be_valid }
  end

  context 'associations' do
    let(:journal_entry_line) { FactoryBot.build(:journal_entry_line) }

    it { expect(journal_entry_line).to belong_to(:journal_entry) }
    it { expect(journal_entry_line).to belong_to(:account) }
    it { expect(journal_entry_line).to belong_to(:contact).optional }
    it { expect(journal_entry_line).to belong_to(:business_unit).optional }
  end

  context 'validations' do
    let(:journal_entry_line) { FactoryBot.create(:journal_entry_line) }

    it { expect(journal_entry_line).to validate_presence_of(:journal_entry) }
    it { expect(journal_entry_line).to validate_presence_of(:account) }

    context 'when account is ACCOUNTS_RECEIVABLE' do
      before(:each) do
        journal_entry_line.account = journal_entry_line.journal_entry.organization.accounts.find_by(internal_code: 'ACCOUNTS_RECEIVABLE')
      end
      it { expect(journal_entry_line).to validate_presence_of(:contact) }
    end
  end

  context 'callbacks' do
    let(:journal_entry_line) { FactoryBot.build(:journal_entry_line) }

    it { expect(journal_entry_line).to callback(:update_calculated_fields).before(:save) }
    it { expect(journal_entry_line).to callback(:update_account).after(:save) }
    it { expect(journal_entry_line).to callback(:can_update?).before(:update) }
    it { expect(journal_entry_line).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:journal_entry_line) { FactoryBot.create(:journal_entry_line) }
      before(:each) { journal_entry_line.update(updated_at: DateTime.now.zone) }

      it { expect(journal_entry_line.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:journal_entry_line) { FactoryBot.create(:journal_entry_line) }
      before(:each) { journal_entry_line.destroy }

      it { expect(journal_entry_line.errors.size).to eq(0) }
    end
  end
end
