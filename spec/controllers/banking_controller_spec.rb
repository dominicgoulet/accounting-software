# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BankingController do
  before(:each) { create_and_login }

  describe 'POST /banking/create_link_token' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create_link_token

        expect(response).to have_http_status(200)
      end

      it 'returns a json link_token' do
        post :create_link_token

        expect(json).to have_json_path('link_token')
        expect(json).to have_json_type(String).at_path('link_token')
      end
    end
  end

  #
  # We need to mock the Banking API
  #

  # describe 'POST /banking/update_link_token' do
  #   let(:bank_credential) { FactoryBot.create(:bank_credential, organization: current_organization) }

  #   context 'with valid parameters' do
  #     it 'returns a valid http code' do
  #       post :update_link_token, params: { id: bank_credential.id }

  #       expect(response).to have_http_status(200)
  #     end

  #     it 'returns a json link_token' do
  #       post :update_link_token, params: { id: bank_credential.id }

  #       expect(json).to have_json_path('link_token')
  #       expect(json).to have_json_type(String).at_path('link_token')
  #     end
  #   end
  # end

  #
  # We need to mock the Banking API
  #
  # describe 'POST /banking/exchange_public_token' do
  #   context 'with valid parameters' do
  #     it 'returns a valid http code' do
  #       post :exchange_public_token, params: { public_token: 'some-public-token' }

  #       expect(response).to have_http_status(200)
  #     end

  #     it 'returns a json link_token' do
  #       post :exchange_public_token, params: { public_token: 'some-public-token' }

  #       expect(json).to have_json_path('link_token')
  #       expect(json).to have_json_type(String).at_path('link_token')
  #     end
  #   end
  # end
end
