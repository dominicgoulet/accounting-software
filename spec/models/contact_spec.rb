# frozen_string_literal: true

# == Schema Information
#
# Table name: contacts
#
#  id              :uuid             not null, primary key
#  company_name    :string
#  currency        :string
#  display_name    :string
#  email           :string
#  first_name      :string
#  is_customer     :boolean
#  is_employee     :boolean
#  is_vendor       :boolean
#  last_name       :string
#  phone_number    :string
#  status          :string
#  website         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
require 'rails_helper'

RSpec.describe Contact do
  context 'has a valid factory' do
    let(:contact) { FactoryBot.build(:contact) }

    it { expect(contact).to be_valid }
  end

  context 'associations' do
    let(:contact) { FactoryBot.build(:contact) }

    it { expect(contact).to belong_to(:organization) }

    it { expect(contact).to have_many(:estimates) }
    it { expect(contact).to have_many(:invoices) }
    it { expect(contact).to have_many(:deposits) }
    it { expect(contact).to have_many(:purchase_orders) }
    it { expect(contact).to have_many(:bills) }
    it { expect(contact).to have_many(:expenses) }
  end

  context 'validations' do
    let(:contact) { FactoryBot.build(:contact) }

    it { expect(contact).to validate_presence_of(:organization) }
    it { expect(contact).to validate_presence_of(:display_name) }
    it { expect(contact).to validate_uniqueness_of(:display_name).case_insensitive.scoped_to(:organization_id) }

    it { expect(contact).to enumerize(:status).in(:active, :archived).with_default(:active) }
  end

  context 'callbacks' do
    let(:contact) { FactoryBot.build(:contact) }

    it { expect(contact).to callback(:can_update?).before(:update) }
    it { expect(contact).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context 'shorthands' do
      context '.address' do
        let(:contact) { FactoryBot.create(:contact) }

        it { expect(contact.address).not_to be_nil }
      end

      context '.classification' do
        let(:contact) { FactoryBot.create(:contact) }

        it { expect(contact.classification).to be_nil }
      end

      context '.avatar_url' do
        let(:contact) { FactoryBot.create(:contact) }

        it { expect(contact.avatar_url).not_to be_nil }
      end
    end
  end

  context 'permissions' do
    context 'update' do
      let(:contact) { FactoryBot.create(:contact) }
      before(:each) { contact.update(updated_at: DateTime.now.zone) }

      it { expect(contact.errors.size).to eq(0) }
    end

    context 'delete' do
      context 'when contact can be deleted' do
        let(:contact) { FactoryBot.create(:contact) }
        before(:each) { contact.destroy }

        it { expect(contact.errors.size).to eq(0) }
      end

      context 'when it has an accounting document' do
        let(:contact) { FactoryBot.create(:contact) }
        before(:each) { contact.organization.invoices.create(contact:, date: Date.today) }
        before(:each) { contact.destroy }

        it { expect(contact.invoices.size).to eq(1) }
        it { expect(contact.errors.size).to eq(1) }
      end
    end
  end
end
