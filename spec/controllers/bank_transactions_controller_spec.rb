# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BankTransactionsController do
  before(:each) { create_and_login }

  #
  # We need to mock the Banking API
  #

  # describe 'PATCH /bank_transactions/:id/reset' do
  #   context 'with a valid identifier and valid parameters' do
  #     let(:bank_transaction) { FactoryBot.create(:bank_transaction) }

  #     it 'returns a valid http code' do
  #       patch :promote, params: { id: bank_transaction.id }, format: :turbo_stream

  #       expect(response).to have_http_status(200)
  #     end

  #     it 'updates the bank_transaction' do
  #       patch :promote, params: { id: bank_transaction.id }
  #       bank_transaction.reload

  #       expect(bank_transaction.status).to eq('imported')
  #     end

  #     it 'creates an audit event' do
  #       expect do
  #         patch :promote, params: {
  #           id: bank_transaction.id
  #         }
  #       end.to change(AuditEvent, :count)
  #     end
  #   end
  # end
end
