# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsController do
  before(:each) { create_and_login }

  #
  # We need to mock the Banking API
  #

  # describe 'GET /transactions/:bank_account_id' do
  #   let(:bank_account) { FactoryBot.create(:bank_account, organization: current_organization) }

  #   context 'with valid information' do
  #     it 'will render index' do
  #       get :index, params: { bank_account_id: bank_account.id }

  #       expect(response).to have_http_status(200)
  #     end
  #   end
  # end

  # describe 'GET /transactions/:bank_account_id/all' do
  #   let(:bank_account) { FactoryBot.create(:bank_account, organization: current_organization) }

  #   context 'with valid information' do
  #     it 'will render all' do
  #       get :all, params: { bank_account_id: bank_account.id }

  #       expect(response).to have_http_status(200)
  #     end
  #   end
  # end
end
