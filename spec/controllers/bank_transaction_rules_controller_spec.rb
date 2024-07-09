# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BankTransactionRulesController do
  before(:each) { create_and_login }

  describe 'GET /bank_transaction_rules' do
    context 'with valid information' do
      it 'will render all bank_transaction_rules' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /bank_transaction_rules/:id' do
    context 'with a valid identifier' do
      let(:bank_transaction_rule) { current_organization.bank_transaction_rules.create(name: 'Default') }

      it 'renders the view' do
        get :show, params: { id: bank_transaction_rule.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        get :show, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /bank_transaction_rules/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new

        expect(response).to have_http_status(200)
      end
    end

    #
    # We need to mock the Banking API
    #

    # context 'with valid parameters and a bank_transaction_id' do
    #   let(:bank_transaction) { FactoryBot.create(:bank_transaction) }

    #   it 'renders the view' do
    #     get :new, params: { bank_transaction_id: bank_transaction.id }

    #     expect(response).to have_http_status(200)
    #   end
    # end
  end

  describe 'POST /bank_transaction_rules' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          bank_transaction_rule: {
            name: 'The Jedis'
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new bank_transaction_rule' do
        expect do
          post :create, params: {
            bank_transaction_rule: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(BankTransactionRule, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            bank_transaction_rule: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          bank_transaction_rule: {
            name: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new bank_transaction_rule' do
        expect do
          post :create, params: {
            bank_transaction_rule: {
              name: ''
            }
          }, format: :html
        end.not_to change(BankTransactionRule, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            bank_transaction_rule: {
              name: ''
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /bank_transaction_rules/:id/edit' do
    context 'with a valid identifier' do
      let(:bank_transaction_rule) { current_organization.bank_transaction_rules.create(name: 'Default') }

      it 'renders the view' do
        get :edit, params: { id: bank_transaction_rule.id }

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        get :edit, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /bank_transaction_rules/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:bank_transaction_rule) { current_organization.bank_transaction_rules.create(name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: bank_transaction_rule.id, bank_transaction_rule: { name: 'The Jedis' } },
                       format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the bank_transaction_rule' do
        bank_transaction_rule = current_organization.bank_transaction_rules.create(name: 'Default name')
        patch :update, params: { id: bank_transaction_rule.id, bank_transaction_rule: { name: 'The Jedis' } },
                       format: :turbo_stream
        bank_transaction_rule.reload

        expect(bank_transaction_rule.name).to eq('The Jedis')
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: bank_transaction_rule.id, bank_transaction_rule: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:bank_transaction_rule) { current_organization.bank_transaction_rules.create(name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: bank_transaction_rule.id, bank_transaction_rule: { name: '' } }

        expect(response).to have_http_status(422)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        patch :update, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /bank_transaction_rules/:id/enforce' do
    context 'with a valid identifier and valid parameters' do
      let(:bank_transaction_rule) { current_organization.bank_transaction_rules.create(name: 'Default') }

      it 'renders the view' do
        patch :enforce, params: { id: bank_transaction_rule.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'DELETE /bank_transaction_rules/:id' do
    context 'with a valid identifier' do
      it 'renders the view' do
        bank_transaction_rule = current_organization.bank_transaction_rules.create(name: 'Default name')

        delete :destroy, params: { id: bank_transaction_rule.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the bank_transaction_rule' do
        bank_transaction_rule = current_organization.bank_transaction_rules.create(name: 'Default name')

        expect do
          delete :destroy, params: { id: bank_transaction_rule.id },
                           format: :turbo_stream
        end.to change(BankTransactionRule, :count)
      end

      it 'creates an audit event' do
        bank_transaction_rule = current_organization.bank_transaction_rules.create(name: 'Default name')

        expect do
          delete :destroy, params: {
            id: bank_transaction_rule.id
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        delete :destroy, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end

      it 'does not eletes the bank_transaction_rule' do
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

  describe 'DELETE /bank_transaction_rules' do
    context 'with valid ids' do
      it 'renders the view' do
        bank_transaction_rule_1 = current_organization.bank_transaction_rules.create(name: 'Default name 1')
        bank_transaction_rule_2 = current_organization.bank_transaction_rules.create(name: 'Default name 2')
        bank_transaction_rule_3 = current_organization.bank_transaction_rules.create(name: 'Default name 3')

        delete :destroy_many, params: {
          item_ids: [bank_transaction_rule_1.id, bank_transaction_rule_2.id, bank_transaction_rule_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the bank_transaction_rules' do
        bank_transaction_rule_1 = current_organization.bank_transaction_rules.create(name: 'Default name 1')
        bank_transaction_rule_2 = current_organization.bank_transaction_rules.create(name: 'Default name 2')
        bank_transaction_rule_3 = current_organization.bank_transaction_rules.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [bank_transaction_rule_1.id, bank_transaction_rule_2.id, bank_transaction_rule_3.id]
          }, format: :turbo_stream
        end.to change(BankTransactionRule, :count).by(-3)
      end

      it 'creates an audit event per bank_transaction_rule deleted' do
        bank_transaction_rule_1 = current_organization.bank_transaction_rules.create(name: 'Default name 1')
        bank_transaction_rule_2 = current_organization.bank_transaction_rules.create(name: 'Default name 2')
        bank_transaction_rule_3 = current_organization.bank_transaction_rules.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [bank_transaction_rule_1.id, bank_transaction_rule_2.id, bank_transaction_rule_3.id]
          }, format: :turbo_stream
        end.to change(AuditEvent, :count).by(3)
      end
    end

    context 'with invalid ids' do
      it 'renders the view' do
        delete :destroy_many, params: {
          item_ids: %w[invalid-id-1 invalid-id-2]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not deletes the bank_transaction_rules' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(BankTransactionRule, :count)
      end

      it 'does not creates an audit event per bank_transaction_rule deleted' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
