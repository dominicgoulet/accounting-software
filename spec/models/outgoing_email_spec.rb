# frozen_string_literal: true

# == Schema Information
#
# Table name: outgoing_emails
#
#  id                  :uuid             not null, primary key
#  body                :text
#  recipients          :string           default([]), is an Array
#  related_object_type :string
#  subject             :string
#  title               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  organization_id     :uuid
#  related_object_id   :uuid
#
require 'rails_helper'

RSpec.describe OutgoingEmail do
  context 'has a valid factory' do
    let(:outgoing_email) { FactoryBot.build(:outgoing_email) }

    it { expect(outgoing_email).to be_valid }
  end

  context 'associations' do
    let(:outgoing_email) { FactoryBot.build(:outgoing_email) }

    it { expect(outgoing_email).to belong_to(:organization) }
    it { expect(outgoing_email).to belong_to(:related_object).optional }
  end

  context 'validations' do
    let(:outgoing_email) { FactoryBot.build(:outgoing_email) }

    it { expect(outgoing_email).to validate_presence_of(:organization) }
    it { expect(outgoing_email).to validate_presence_of(:recipients) }
    it { expect(outgoing_email).to validate_presence_of(:subject) }
  end

  context 'callbacks' do
    let(:outgoing_email) { FactoryBot.build(:outgoing_email) }

    it { expect(outgoing_email).to callback(:can_update?).before(:update) }
    it { expect(outgoing_email).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
    context '.send!' do
      let(:outgoing_email) { FactoryBot.build(:outgoing_email) }

      it { expect(outgoing_email.send!).to be_truthy }
    end
  end

  context 'permissions' do
    context 'update' do
      let(:outgoing_email) { FactoryBot.create(:outgoing_email) }
      before(:each) { outgoing_email.update(updated_at: DateTime.now.zone) }

      it { expect(outgoing_email.errors.size).to eq(0) }
    end

    context 'delete' do
      let(:outgoing_email) { FactoryBot.create(:outgoing_email) }
      before(:each) { outgoing_email.destroy }

      it { expect(outgoing_email.errors.size).to eq(0) }
    end
  end
end
