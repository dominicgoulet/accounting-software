# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BankTransactionRuleMatchesController do
  before(:each) { create_and_login }

  describe 'PATCH /bank_transaction_rule_matches/:id/apply' do
    #
    # We need to mock the Banking API
    #

    # context 'with a valid identifier and valid parameters' do
    #   let(:bank_transaction_rule_match) { FactoryBot.create(:bank_transaction_rule_match, organization: current_organization) }

    #   it 'renders the view' do
    #     patch :apply, params: { id: bank_transaction_rule_match.id }, format: :turbo_stream

    #     expect(response).to have_http_status(200)
    #   end
    # end

    context 'with an invalid identifier' do
      it 'returns an invalid http code' do
        patch :apply, params: { id: 'invalid-id' }, format: :turbo_stream

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /bank_transaction_rule_matches/:id' do
    #
    # We need to mock the Banking API
    #

    # context 'with a valid identifier' do
    #   let(:bank_transaction_rule_match) { FactoryBot.create(:bank_transaction_rule_match, organization: current_organization) }

    #   it 'renders the view' do
    #     delete :destroy, params: { id: bank_transaction_rule_match.id }, format: :turbo_stream

    #     expect(response).to have_http_status(200)
    #   end

    #   it 'deletes the bank_transaction_rule_match' do
    #     expect { delete :destroy, params: { id: bank_transaction_rule_match.id }, format: :turbo_stream }.to change(BankTransactionRule, :count)
    #   end

    #   it 'creates an audit event' do
    #     expect do
    #       delete :destroy, params: {
    #         id: bank_transaction_rule_match.id
    #       }, format: :turbo_stream
    #     end.to change(AuditEvent, :count)
    #   end
    # end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        delete :destroy, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end

      it 'does not deletes the bank_transaction_rule_match' do
        expect do
          delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream
        end.not_to change(BankTransactionRule, :count)
      end

      it 'does not creates an audit event' do
        expect do
          delete :destroy, params: {
            id: 'invalid-id'
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
