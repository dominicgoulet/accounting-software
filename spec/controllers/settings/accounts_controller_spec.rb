# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::AccountsController do
  before(:each) { create_and_login }

  describe 'GET /settings/accounts' do
    context 'with no classification' do
      it 'will redirect to asset classification' do
        get :index

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(accounts_classification_path('asset'))
      end
    end

    context 'with a valid classification' do
      it 'will render asset classified accounts' do
        get :index, params: { classification: 'asset' }

        expect(response).to have_http_status(200)
      end

      it 'will render liability classified accounts' do
        get :index, params: { classification: 'liability' }

        expect(response).to have_http_status(200)
      end

      it 'will render equity classified accounts' do
        get :index, params: { classification: 'equity' }

        expect(response).to have_http_status(200)
      end

      it 'will render income classified accounts' do
        get :index, params: { classification: 'income' }

        expect(response).to have_http_status(200)
      end

      it 'will render expense classified accounts' do
        get :index, params: { classification: 'expense' }

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid classification' do
      it 'will redirect to asset classification' do
        get :index, params: { classification: 'unknown_classification' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(accounts_classification_path('asset'))
      end
    end
  end

  describe 'GET /settings/accounts/:id' do
    context 'with a valid identifier' do
      let(:account) { current_organization.accounts.first }

      it 'renders the view' do
        get :show, params: { id: account.id }

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

  describe 'GET /settings/accounts/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new, params: { classification: 'expense' }

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /settings/accounts/new_contextual' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new_contextual

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /settings/accounts' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          account: {
            name: 'Lightsaber Parts',
            classification: 'asset'
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new account' do
        expect do
          post :create, params: {
            account: {
              name: 'Lightsaber Parts',
              classification: 'asset'
            }
          }, format: :turbo_stream
        end.to change(Account, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            account: {
              name: 'Lightsaber Parts',
              classification: 'asset'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          account: {
            classification: 'asset'
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new account' do
        expect do
          post :create, params: {
            account: {
              classification: 'asset'
            }
          }, format: :html
        end.not_to change(Account, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            account: {
              classification: 'asset'
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /settings/accounts/:id/edit' do
    context 'with a valid identifier' do
      let(:account) { current_organization.accounts.first }

      it 'renders the view' do
        get :edit, params: { id: account.id }

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

  describe 'PATCH /settings/accounts/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:account) { current_organization.accounts.first }

      it 'renders the view' do
        patch :update, params: { id: account.id, account: { name: 'Lightsaber Parts & Hilts' } }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the account' do
        account = current_organization.accounts.create(name: 'Default name')
        patch :update, params: { id: account.id, account: { name: 'Lightsaber Parts & Hilts' } }, format: :turbo_stream
        account.reload

        expect(account.name).to eq('Lightsaber Parts & Hilts')
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: account.id, account: {
              name: 'Lightsaber Parts & Hilts'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:account) { current_organization.accounts.first }

      it 'renders the view' do
        patch :update, params: { id: account.id, account: { classification: 'unknown classification' } }

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

  describe 'DELETE /settings/accounts/:id/edit' do
    context 'with a valid identifier' do
      it 'renders the view' do
        account = current_organization.accounts.create(name: 'Default name')

        delete :destroy, params: { id: account.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the account' do
        account = current_organization.accounts.create(name: 'Default name')

        expect { delete :destroy, params: { id: account.id }, format: :turbo_stream }.to change(Account, :count)
      end

      it 'creates an audit event' do
        account = current_organization.accounts.create(name: 'Default name')

        expect do
          delete :destroy, params: {
            id: account.id
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier but an account that cannot be deleted' do
      let(:account) { current_organization.accounts.where(system: true).first }

      it 'renders the view' do
        delete :destroy, params: { id: account.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not delete the account' do
        expect { delete :destroy, params: { id: account.id }, format: :turbo_stream }.not_to change(Account, :count)
      end

      it 'does not creates an audit event' do
        expect do
          delete :destroy, params: {
            id: account.id
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        delete :destroy, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end

      it 'does not eletes the account' do
        expect { delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream }.not_to change(Account, :count)
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

  describe 'DELETE /settings/accounts' do
    context 'with valid ids' do
      it 'renders the view' do
        account_1 = current_organization.accounts.create(name: 'Default name 1')
        account_2 = current_organization.accounts.create(name: 'Default name 2')
        account_3 = current_organization.accounts.create(name: 'Default name 3')

        delete :destroy_many, params: {
          item_ids: [account_1.id, account_2.id, account_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the accounts' do
        account_1 = current_organization.accounts.create(name: 'Default name 1')
        account_2 = current_organization.accounts.create(name: 'Default name 2')
        account_3 = current_organization.accounts.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [account_1.id, account_2.id, account_3.id]
          }, format: :turbo_stream
        end.to change(Account, :count).by(-3)
      end

      it 'creates an audit event per item deleted' do
        account_1 = current_organization.accounts.create(name: 'Default name 1')
        account_2 = current_organization.accounts.create(name: 'Default name 2')
        account_3 = current_organization.accounts.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [account_1.id, account_2.id, account_3.id]
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

      it 'does not deletes the accounts' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(Account, :count)
      end

      it 'does not creates an audit event per item deleted' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end

    context 'with accounts that cannot be deleted' do
      it 'renders the view' do
        account_1 = current_organization.accounts.where(system: true).first
        account_2 = current_organization.accounts.where(system: true).second
        account_3 = current_organization.accounts.where(system: true).third

        delete :destroy_many, params: {
          item_ids: [account_1.id, account_2.id, account_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not deletes the accounts' do
        account_1 = current_organization.accounts.where(system: true).first
        account_2 = current_organization.accounts.where(system: true).second
        account_3 = current_organization.accounts.where(system: true).third

        expect do
          delete :destroy_many, params: {
            item_ids: [account_1.id, account_2.id, account_3.id]
          }, format: :turbo_stream
        end.not_to change(Account, :count)
      end

      it 'does not creates an audit event per item deleted' do
        account_1 = current_organization.accounts.where(system: true).first
        account_2 = current_organization.accounts.where(system: true).second
        account_3 = current_organization.accounts.where(system: true).third

        expect do
          delete :destroy_many, params: {
            item_ids: [account_1.id, account_2.id, account_3.id]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end

    context 'with a mix of everything' do
    end
  end
end
