# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id                 :uuid             not null, primary key
#  buy                :boolean          default(FALSE)
#  buy_description    :string
#  buy_price          :decimal(, )
#  cup                :string
#  name               :string
#  sell               :boolean          default(FALSE)
#  sell_description   :string
#  sell_price         :decimal(, )
#  status             :string
#  ugs                :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  expense_account_id :uuid
#  income_account_id  :uuid
#  organization_id    :uuid             not null
#
require 'rails_helper'

RSpec.describe Item do
  context 'has a valid factory' do
    let(:item) { FactoryBot.build(:item) }

    it { expect(item).to be_valid }
  end

  context 'associations' do
    let(:item) { FactoryBot.build(:item) }

    it { expect(item).to belong_to(:organization) }
    it { expect(item).to belong_to(:income_account).optional }
    it { expect(item).to belong_to(:expense_account).optional }

    it { expect(item).to have_many(:commercial_document_lines) }
  end

  context 'validations' do
    let(:item) { FactoryBot.create(:item) }

    it { expect(item).to validate_presence_of(:organization) }
    it { expect(item).to validate_presence_of(:name) }

    it { expect(item).to enumerize(:status).in(:active, :archived).with_default(:active) }

    context 'when sell?' do
      let(:account) { FactoryBot.create(:account) }
      let(:buy_item) { FactoryBot.create(:item, sell: true, income_account: account) }

      it { expect(buy_item).to validate_presence_of(:income_account) }
    end

    context 'when buy?' do
      let(:account) { FactoryBot.create(:account) }
      let(:sell_item) { FactoryBot.create(:item, buy: true, expense_account: account) }

      it { expect(sell_item).to validate_presence_of(:expense_account) }
    end
  end

  context 'callbacks' do
    let(:item) { FactoryBot.build(:item) }

    it { expect(item).to callback(:can_update?).before(:update) }
    it { expect(item).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context 'shorthands' do
      context '.display_name' do
        let(:item) { FactoryBot.create(:item) }

        it { expect(item.display_name).to eq(item.name) }
      end
    end
  end

  context 'permissions' do
    context 'update' do
      let(:item) { FactoryBot.create(:item) }
      before(:each) { item.update(updated_at: DateTime.now.zone) }

      it { expect(item.errors.size).to eq(0) }
    end

    context 'delete' do
      context 'when item can be deleted' do
        let(:item) { FactoryBot.create(:item) }
        before(:each) { item.destroy }

        it { expect(item.errors.size).to eq(0) }
      end

      context 'when it is used by a commercial_document_line' do
        let(:contact) { FactoryBot.create(:contact) }
        let(:item) { FactoryBot.create(:item) }
        before(:each) do
          ac = item.organization.accounts.create(name: 'My Account')
          cd = item.organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
          dl = cd.lines.create(account: ac, item:)
        end
        before(:each) { item.destroy }

        it { expect(item.commercial_document_lines.size).to eq(1) }
        it { expect(item.errors.size).to eq(1) }
      end
    end
  end
end
