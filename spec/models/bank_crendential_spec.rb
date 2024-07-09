# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_credentials
#
#  id              :uuid             not null, primary key
#  access_token    :string
#  error_code      :string
#  error_type      :string
#  last_sync_at    :datetime
#  latest_cursor   :string
#  logo            :text
#  name            :string
#  primary_color   :string
#  public_token    :string
#  status          :string
#  url             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  institution_id  :string
#  organization_id :uuid
#
require 'rails_helper'

RSpec.describe BankCredential do
  context 'has a valid factory' do
    let(:bank_credential) { FactoryBot.build(:bank_credential) }

    it { expect(bank_credential).to be_valid }
  end

  context 'associations' do
    let(:bank_credential) { FactoryBot.build(:bank_credential) }

    it { expect(bank_credential).to belong_to(:organization) }

    it { expect(bank_credential).to have_many(:bank_accounts) }
  end

  context 'validations' do
    let(:bank_credential) { FactoryBot.build(:bank_credential) }

    it { expect(bank_credential).to validate_presence_of(:organization) }
    it { expect(bank_credential).to validate_presence_of(:access_token) }

    it { expect(bank_credential).to enumerize(:status).in(:ok, :error).with_default(:ok) }
  end

  context 'callbacks' do
    let(:bank_credential) { FactoryBot.build(:bank_credential) }

    it { expect(bank_credential).to callback(:fetch_institution_info).before(:create) }
    it { expect(bank_credential).to callback(:fetch_accounts_info).after(:create) }
    it { expect(bank_credential).to callback(:can_update?).before(:update) }
    it { expect(bank_credential).to callback(:can_delete?).before(:destroy) }
  end

  context 'methods' do
  end

  #
  # We need to mock the Banking API
  #

  # context 'permissions' do
  #   context 'update' do
  #     let(:bank_credential) { FactoryBot.build(:bank_credential) }
  #     before(:each) { bank_credential.update(updated_at: DateTime.now.zone) }

  #     it { expect(bank_credential.errors.size).to eq(0) }
  #   end

  #   context 'delete' do
  #     let(:bank_credential) { FactoryBot.build(:bank_credential) }
  #     before(:each) { bank_credential.destroy }

  #     it { expect(bank_credential.errors.size).to eq(0) }
  #   end
  # end
end
