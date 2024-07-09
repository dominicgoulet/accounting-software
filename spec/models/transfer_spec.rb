# frozen_string_literal: true

# == Schema Information
#
# Table name: transfers
#
#  id              :uuid             not null, primary key
#  amount          :decimal(, )
#  date            :date
#  note            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  from_account_id :uuid
#  organization_id :uuid
#  to_account_id   :uuid
#
require 'rails_helper'

RSpec.describe Transfer do
  context 'has a valid factory' do
    let(:transfer) { FactoryBot.build(:transfer) }

    it { expect(transfer).to be_valid }
  end

  context 'associations' do
    let(:transfer) { FactoryBot.build(:transfer) }

    it { expect(transfer).to belong_to(:organization) }
    it { expect(transfer).to belong_to(:from_account) }
    it { expect(transfer).to belong_to(:to_account) }

    it { expect(transfer).to have_many_attached(:attached_files) }
  end

  context 'validations' do
    let(:transfer) { FactoryBot.build(:transfer) }

    it { expect(transfer).to validate_presence_of(:organization) }
    it { expect(transfer).to validate_presence_of(:from_account) }
    it { expect(transfer).to validate_presence_of(:to_account) }
    it { expect(transfer).to validate_presence_of(:date) }

    it { expect(transfer).to enumerize(:status).in(:new).with_default(:new) }
  end

  context 'callbacks' do
    let(:transfer) { FactoryBot.build(:transfer) }

    it { expect(transfer).to callback(:can_update?).before(:update) }
    it { expect(transfer).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  context 'permissions' do
    context 'update' do
      let(:transfer) { FactoryBot.create(:transfer) }
      before(:each) { transfer.update(updated_at: DateTime.now.zone) }

      it { expect(transfer.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:transfer) { FactoryBot.create(:transfer) }
      before(:each) { transfer.destroy }

      it { expect(transfer.errors.size).to eq(0) }
    end
  end
end
