# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entries
#
#  id                           :uuid             not null, primary key
#  currency                     :string
#  date                         :date
#  exchange_rate                :decimal(, )
#  integration_journalable_type :string
#  journalable_type             :string
#  narration                    :string
#  total_credit                 :decimal(, )
#  total_debit                  :decimal(, )
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  integration_id               :uuid
#  integration_journalable_id   :string
#  journalable_id               :uuid
#  organization_id              :uuid
#
require 'rails_helper'

RSpec.describe JournalEntry do
  context 'has a valid factory' do
    let(:journal_entry) { FactoryBot.build(:journal_entry) }

    it { expect(journal_entry).to be_valid }
  end

  context 'associations' do
    let(:journal_entry) { FactoryBot.build(:journal_entry) }

    it { expect(journal_entry).to belong_to(:organization) }
    it { expect(journal_entry).to belong_to(:integration) }
    it { expect(journal_entry).to belong_to(:journalable).optional }

    it { expect(journal_entry).to have_many(:journal_entry_lines) }
    it { expect(journal_entry).to have_many_attached(:attached_files) }
  end

  context 'validations' do
    let(:journal_entry) { FactoryBot.create(:journal_entry) }

    it { expect(journal_entry).to validate_presence_of(:organization) }
    it { expect(journal_entry).to validate_presence_of(:integration) }
    it { expect(journal_entry).to validate_presence_of(:date) }

    it { expect(journal_entry).to accept_nested_attributes_for(:journal_entry_lines).allow_destroy(true) }

    context 'journal_entry_lines should not accept blank account_id' do
      let(:account) { FactoryBot.create(:account) }

      it {
        expect do
          FactoryBot.create(:journal_entry,
                            journal_entry_lines_attributes: [account_id: nil])
        end.to_not change(JournalEntryLine, :count)
      }
      it {
        expect do
          FactoryBot.create(:journal_entry,
                            journal_entry_lines_attributes: [account_id: account.id])
        end.to change(JournalEntryLine, :count)
      }
    end
  end

  context 'callbacks' do
    let(:journal_entry) { FactoryBot.build(:journal_entry) }

    it { expect(journal_entry).to callback(:update_calculated_fields).before(:save) }
    it { expect(journal_entry).to callback(:can_update?).before(:update) }
    it { expect(journal_entry).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context 'shorthands' do
      context '.files' do
        context 'when customn journal entry' do
          let(:journal_entry) { FactoryBot.create(:journal_entry) }

          it { expect(journal_entry.files.size).to eq(0) }
        end

        context 'when ninetyfour journalable' do
          let(:integration) { FactoryBot.create(:integration, system: true, internal_code: 'NINETYFOUR') }
          let(:invoice) { FactoryBot.create(:invoice) }
          let(:journal_entry) { FactoryBot.create(:journal_entry, integration:, journalable: invoice) }

          it { expect(journal_entry.files.size).to eq(0) }
        end
      end
    end
  end

  context 'permissions' do
    context 'update' do
      context 'when it is a custom entry' do
        let(:journal_entry) { FactoryBot.create(:journal_entry) }
        before(:each) { journal_entry.update(updated_at: DateTime.now.zone) }

        it { expect(journal_entry.errors.size).to eq(0) }
      end

      # This is the expected behavior, but it does not work as the invoice has to update the journal_entry
      # once it has been updated.

      # context 'when it is attached to a ninetyfour accounting document (a.k.a.: journalable)' do
      #   let(:invoice) { FactoryBot.create(:invoice) }
      #   let(:journal_entry) { FactoryBot.create(:journal_entry, journalable: invoice) }

      #   before(:each) { journal_entry.update(updated_at: DateTime.now.zone) }

      #   it { expect(journal_entry.errors.size).to eq(1) }
      # end
    end

    context 'delete' do
      context 'when it is a custom entry' do
        let(:journal_entry) { FactoryBot.create(:journal_entry) }
        before(:each) { journal_entry.destroy }

        it { expect(journal_entry.errors.size).to eq(0) }
      end

      context 'when it is attached to a ninetyfour accounting document (a.k.a.: journalable)' do
        let(:invoice) { FactoryBot.create(:invoice) }
        let(:journal_entry) { FactoryBot.create(:journal_entry, journalable: invoice) }

        before(:each) { journal_entry.destroy }

        it { expect(journal_entry.errors.size).to eq(1) }
      end
    end
  end
end
