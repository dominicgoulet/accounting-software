# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransfersController do
  before(:each) { create_and_login }

  describe 'GET /transfers' do
    context 'with valid information' do
      it 'will render all transfers' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /transfers/:id' do
    context 'with a valid identifier' do
      let(:transfer) { FactoryBot.create(:transfer, organization: current_organization) }

      it 'renders the view' do
        get :show, params: { id: transfer.id }

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

  describe 'GET /transfers/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /transfers' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          transfer: {
            from_account_id: current_organization.accounts.first.id,
            to_account_id: current_organization.accounts.second.id,
            date: Date.today
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new transfer' do
        expect do
          post :create, params: {
            transfer: {
              from_account_id: current_organization.accounts.first.id,
              to_account_id: current_organization.accounts.second.id,
              date: Date.today
            }
          }, format: :turbo_stream
        end.to change(Transfer, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            transfer: {
              from_account_id: current_organization.accounts.first.id,
              to_account_id: current_organization.accounts.second.id,
              date: Date.today
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          transfer: {
            date: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new transfer' do
        expect do
          post :create, params: {
            transfer: {
              date: ''
            }
          }, format: :html
        end.not_to change(Transfer, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            transfer: {
              date: ''
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /transfers/:id/edit' do
    context 'with a valid identifier' do
      let(:transfer) { FactoryBot.create(:transfer, organization: current_organization) }

      it 'renders the view' do
        get :edit, params: { id: transfer.id }

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

  describe 'PATCH /transfers/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:transfer) { FactoryBot.create(:transfer, organization: current_organization) }

      it 'renders the view' do
        patch :update, params: { id: transfer.id, transfer: { date: Date.today - 1 } }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the transfer' do
        patch :update, params: { id: transfer.id, transfer: { date: Date.today - 1 } }, format: :turbo_stream
        transfer.reload

        expect(transfer.date).to eq(Date.today - 1)
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: transfer.id, transfer: {
              date: Date.today - 1
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:transfer) { FactoryBot.create(:transfer, organization: current_organization) }

      it 'renders the view' do
        patch :update, params: { id: transfer.id, transfer: { date: '' } }

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

  describe 'DELETE /transfers/:id' do
    context 'with a valid identifier' do
      it 'renders the view' do
        transfer = FactoryBot.create(:transfer, organization: current_organization)

        delete :destroy, params: { id: transfer.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the transfer' do
        transfer = FactoryBot.create(:transfer, organization: current_organization)

        expect { delete :destroy, params: { id: transfer.id }, format: :turbo_stream }.to change(Transfer, :count)
      end

      it 'creates an audit event' do
        transfer = FactoryBot.create(:transfer, organization: current_organization)

        expect do
          delete :destroy, params: {
            id: transfer.id
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

      it 'does not eletes the transfer' do
        expect { delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream }.not_to change(Transfer, :count)
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

  describe 'DELETE /transfers' do
    context 'with valid ids' do
      it 'renders the view' do
        transfer_1 = FactoryBot.create(:transfer, organization: current_organization)
        transfer_2 = FactoryBot.create(:transfer, organization: current_organization)
        transfer_3 = FactoryBot.create(:transfer, organization: current_organization)

        delete :destroy_many, params: {
          item_ids: [transfer_1.id, transfer_2.id, transfer_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the transfers' do
        transfer_1 = FactoryBot.create(:transfer, organization: current_organization)
        transfer_2 = FactoryBot.create(:transfer, organization: current_organization)
        transfer_3 = FactoryBot.create(:transfer, organization: current_organization)

        expect do
          delete :destroy_many, params: {
            item_ids: [transfer_1.id, transfer_2.id, transfer_3.id]
          }, format: :turbo_stream
        end.to change(Transfer, :count).by(-3)
      end

      it 'creates an audit event per transfer deleted' do
        transfer_1 = FactoryBot.create(:transfer, organization: current_organization)
        transfer_2 = FactoryBot.create(:transfer, organization: current_organization)
        transfer_3 = FactoryBot.create(:transfer, organization: current_organization)

        expect do
          delete :destroy_many, params: {
            item_ids: [transfer_1.id, transfer_2.id, transfer_3.id]
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

      it 'does not deletes the transfers' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(Transfer, :count)
      end

      it 'does not creates an audit event per transfer deleted' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
