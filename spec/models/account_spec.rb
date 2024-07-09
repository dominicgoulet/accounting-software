# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                :uuid             not null, primary key
#  account_type      :string
#  accountable_type  :string
#  classification    :string
#  currency          :string
#  current_balance   :decimal(, )
#  description       :string
#  display_name      :string
#  full_path         :string
#  generated         :boolean          default(FALSE)
#  internal_code     :string
#  name              :string
#  reference         :integer
#  starting_balance  :decimal(, )
#  status            :string
#  system            :boolean          default(FALSE)
#  total_credit      :decimal(, )
#  total_debit       :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  accountable_id    :uuid
#  organization_id   :uuid
#  parent_account_id :uuid
#
require 'rails_helper'

RSpec.describe Account do
  context 'has a valid factory' do
    let(:account) { FactoryBot.build(:account) }

    it { expect(account).to be_valid }
  end

  context 'associations' do
    let(:account) { FactoryBot.build(:account) }

    it { expect(account).to belong_to(:organization) }
    it { expect(account).to belong_to(:parent_account).optional }
    it { expect(account).to belong_to(:accountable).optional }
    it { expect(account).to have_many(:account_taxes) }
    it { expect(account).to have_many(:sales_taxes).through(:account_taxes) }
    it { expect(account).to have_many(:journal_entry_lines) }
    it { expect(account).to have_many(:child_accounts) }
  end

  context 'validations' do
    let(:account) { FactoryBot.build(:account) }

    it { expect(account).to validate_presence_of(:organization) }
    it { expect(account).to validate_presence_of(:name) }

    it {
      expect(account).to enumerize(:classification).in(:asset, :liability, :equity, :income,
                                                       :expense).with_default(:asset)
    }
    it { expect(account).to enumerize(:status).in(:active, :pending, :inactive).with_default(:active) }

    context 'parent_account_cannot_be_itself_or_a_child' do
      context 'with no parent' do
        it { expect(account.errors.size).to eq(0) }
      end

      context 'with self as a parent' do
        before(:each) { account.update(parent_account: account) }

        it { expect(account.errors.size).to eq(1) }
      end

      context 'with child as a parent' do
        let(:child_account) { FactoryBot.build(:account, parent_account: account) }

        before(:each) { account.update(parent_account: child_account) }
        it { expect(account.errors.size).to eq(1) }
      end

      context 'with child of a child as a parent' do
        let(:child_account) { FactoryBot.build(:account, parent_account: account) }
        let(:child_of_a_child_account) { FactoryBot.build(:account, parent_account: child_account) }

        before(:each) { account.update(parent_account: child_of_a_child_account) }
        it { expect(account.errors.size).to eq(1) }
      end

      context 'with any other unrelated as a parent' do
        let(:unrelated_account) { FactoryBot.build(:account) }
        before(:each) { account.update(parent_account: unrelated_account) }

        it { expect(account.errors.size).to eq(0) }
      end
    end
  end

  context 'callbacks' do
    let(:account) { FactoryBot.build(:account) }

    it { expect(account).to callback(:can_update?).before(:update) }
    it { expect(account).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context 'shorthands' do
      context '.display_name' do
        let(:account) { FactoryBot.create(:account, reference: '5000', name: 'Blasters Parts') }

        it { expect(account.display_name).to eq('5000 Blasters Parts') }
      end

      context '.account_type' do
        context 'when system' do
          let(:account) { FactoryBot.create(:account, system: true) }

          it { expect(account.account_type).to eq('System account') }
        end

        context 'when generated for an accountable' do
          let(:sales_tax) { FactoryBot.create(:sales_tax) }
          let(:account) { FactoryBot.create(:account, accountable: sales_tax) }

          it { expect(account.account_type).to eq('Sales tax') }
        end

        context 'when not system and not generated for an accountable' do
          let(:account) { FactoryBot.create(:account) }

          it { expect(account.account_type).to eq('Custom account') }
        end
      end
    end

    context 'parent_accounts' do
      let(:account) { FactoryBot.build(:account) }

      it { expect(account.parent_accounts).to eq([]) }

      context 'when adding a parent' do
        let(:parent_account) { FactoryBot.build(:account) }
        before(:each) { account.update(parent_account:) }

        it { expect(account.parent_accounts).to eq([parent_account]) }

        context 'when adding a grandparent to the parent' do
          let(:grandparent_account) { FactoryBot.build(:account) }
          before(:each) { parent_account.update(parent_account: grandparent_account) }

          it { expect(account.parent_accounts).to eq([grandparent_account, parent_account]) }
        end
      end
    end
  end

  context 'permissions' do
    context 'update' do
      let(:account) { FactoryBot.create(:account) }
      before(:each) { account.update(updated_at: DateTime.now.zone) }

      it { expect(account.errors.size).to eq(0) }
    end

    context 'delete' do
      context 'when account can be deleted' do
        let(:account) { FactoryBot.create(:account) }
        before(:each) { account.destroy }

        it { expect(account.errors.size).to eq(0) }
      end

      context 'when account is system' do
        let(:account) { FactoryBot.create(:account, system: true) }
        before(:each) { account.destroy }

        it { expect(account.errors.size).to eq(1) }
      end

      context 'when used in the journal' do
        let(:account) { FactoryBot.create(:account) }
        before(:each) do
          integration = account.organization.integrations.create(name: 'X-Ray')
          journal_entry = account.organization.journal_entries.create(date: Date.today, integration:)
          journal_entry.journal_entry_lines.create(account:)
        end
        before(:each) { account.destroy }

        it { expect(account.journal_entry_lines.size).to eq(1) }
        it { expect(account.errors.size).to eq(1) }
      end

      context 'when used as the income account of an item' do
        let(:account) { FactoryBot.create(:account) }
        before(:each) do
          account.organization.items.create(name: 'X-Ray', income_account: account)
        end
        before(:each) { account.destroy }

        it { expect(account.errors.size).to eq(1) }
      end

      context 'when used as the expense account of an item' do
        let(:account) { FactoryBot.create(:account) }
        before(:each) do
          account.organization.items.create(name: 'X-Ray', expense_account: account)
        end
        before(:each) { account.destroy }

        it { expect(account.errors.size).to eq(1) }
      end
    end
  end
end
