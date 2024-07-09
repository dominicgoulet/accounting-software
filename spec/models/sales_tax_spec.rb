# frozen_string_literal: true

# == Schema Information
#
# Table name: sales_taxes
#
#  id              :uuid             not null, primary key
#  abbreviation    :string
#  name            :string
#  number          :string
#  rate            :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid             not null
#
require 'rails_helper'

RSpec.describe SalesTax do
  context 'has a valid factory' do
    let(:sales_tax) { FactoryBot.build(:sales_tax) }

    it { expect(sales_tax).to be_valid }
  end

  context 'associations' do
    let(:sales_tax) { FactoryBot.build(:sales_tax) }

    it { expect(sales_tax).to belong_to(:organization) }
    it { expect(sales_tax).to have_many(:journal_entry_lines).through(:account) }
  end

  context 'validations' do
    let(:sales_tax) { FactoryBot.build(:sales_tax) }

    it { expect(sales_tax).to validate_presence_of(:organization) }
    it { expect(sales_tax).to validate_presence_of(:name) }
    it { expect(sales_tax).to validate_presence_of(:rate) }
  end

  context 'callbacks' do
    let(:sales_tax) { FactoryBot.build(:sales_tax) }

    it { expect(sales_tax).to callback(:can_update?).before(:update) }
    it { expect(sales_tax).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:sales_tax) { FactoryBot.create(:sales_tax) }
      before(:each) { sales_tax.update(updated_at: DateTime.now.zone) }

      it { expect(sales_tax.errors.size).to eq(0) }
    end

    context 'delete' do
      context 'when account can be deleted' do
        let(:sales_tax) { FactoryBot.create(:sales_tax) }
        before(:each) { sales_tax.destroy }

        it { expect(sales_tax.errors.size).to eq(0) }
      end

      context 'when used in the journal' do
        let(:sales_tax) { FactoryBot.create(:sales_tax) }
        before(:each) do
          integration = sales_tax.organization.integrations.create(name: 'X-Ray')
          journal_entry = sales_tax.organization.journal_entries.create(date: Date.today, integration:)
          journal_entry.journal_entry_lines.create(account: sales_tax.account)
        end
        before(:each) { sales_tax.destroy }

        it { expect(sales_tax.journal_entry_lines.size).to eq(1) }
        it { expect(sales_tax.errors.size).to eq(1) }
      end
    end
  end
end
