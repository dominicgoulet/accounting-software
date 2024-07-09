# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BankTransactionTransactionablesController do
  before(:each) { create_and_login }

  #
  # We need to mock the Banking API
  #

  # describe 'GET /bank_transaction_transactionables/new' do
  #   context 'with valid parameters' do
  #     let(:bank_transaction) { FactoryBot.create(:bank_transaction, organization: current_organization) }

  #     it 'renders the view' do
  #       get :new, params: { bank_transaction_id: bank_transaction.id }

  #       expect(response).to have_http_status(200)
  #     end
  #   end

  #   context 'with invalid parameters' do
  #     it 'renders the view' do
  #       get :new, params: { bank_transaction_id: 'invalid-id' }

  #       expect(response).to have_http_status(302)
  #       expect(response).to redirect_to(root_path)
  #     end
  #   end
  # end

  # describe 'POST /bank_transaction_transactionables' do
  #   context 'with valid parameters' do
  #     let(:bank_transaction) { FactoryBot.create(:bank_transaction, organization: current_organization) }

  #     it 'returns a valid http code' do
  #       post :create, params: {
  #         bank_transaction_id: bank_transaction.id,
  #         bank_transaction_transactionable: {
  #           transactionable_type: 'Transfer'
  #         }
  #       }, format: :turbo_stream

  #       expect(response).to have_http_status(200)
  #     end

  #     it 'creates a new bank_transaction_transactionable' do
  #       expect do
  #         post :create, params: {
  #           bank_transaction_transactionable: {
  #             name: 'The Jedis'
  #           }
  #         }, format: :turbo_stream
  #       end.to change(BankTransactionTransactionable, :count)
  #     end

  #     it 'creates an audit event' do
  #       expect do
  #         post :create, params: {
  #           bank_transaction_transactionable: {
  #             name: 'The Jedis'
  #           }
  #         }, format: :turbo_stream
  #       end.to change(AuditEvent, :count)
  #     end
  #   end

  #   context 'with invalid parameters' do
  #     it 'does not returns a valid http code' do
  #       post :create, params: {
  #         bank_transaction_transactionable: {
  #           name: ''
  #         }
  #       }, format: :html

  #       expect(response).to have_http_status(422)
  #     end

  #     it 'does not creates a new bank_transaction_transactionable' do
  #       expect do
  #         post :create, params: {
  #           bank_transaction_transactionable: {
  #             name: ''
  #           }
  #         }, format: :html
  #       end.not_to change(BankTransactionTransactionable, :count)
  #     end

  #     it 'does not creates an audit event' do
  #       expect do
  #         post :create, params: {
  #           bank_transaction_transactionable: {
  #             name: ''
  #           }
  #         }, format: :html
  #       end.not_to change(AuditEvent, :count)
  #     end
  #   end
  # end

  # describe 'DELETE /bank_transaction_transactionables/:id' do
  #   context 'with a valid identifier' do
  #     it 'renders the view' do
  #       bank_transaction_transactionable = current_organization.bank_transaction_transactionables.create(name: 'Default name')

  #       delete :destroy, params: { id: bank_transaction_transactionable.id }, format: :turbo_stream

  #       expect(response).to have_http_status(200)
  #     end

  #     it 'deletes the bank_transaction_transactionable' do
  #       bank_transaction_transactionable = current_organization.bank_transaction_transactionables.create(name: 'Default name')

  #       expect { delete :destroy, params: { id: bank_transaction_transactionable.id }, format: :turbo_stream }.to change(BankTransactionTransactionable, :count)
  #     end

  #     it 'creates an audit event' do
  #       bank_transaction_transactionable = current_organization.bank_transaction_transactionables.create(name: 'Default name')

  #       expect do
  #         delete :destroy, params: {
  #           id: bank_transaction_transactionable.id
  #         }, format: :turbo_stream
  #       end.to change(AuditEvent, :count)
  #     end
  #   end

  #   context 'with an invalid identifier' do
  #     it 'redirects after handling the error' do
  #       delete :destroy, params: { id: 'invalid-id' }

  #       expect(response).to have_http_status(302)
  #       expect(response).to redirect_to(root_path)
  #     end

  #     it 'does not eletes the bank_transaction_transactionable' do
  #       expect { delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream }.not_to change(BankTransactionTransactionable, :count)
  #     end

  #     it 'does not creates an audit event' do
  #       expect do
  #         delete :destroy, params: {
  #           id: 'invalid-id'
  #         }, format: :turbo_stream
  #       end.not_to change(AuditEvent, :count)
  #     end
  #   end
  # end
end
