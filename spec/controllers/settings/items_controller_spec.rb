# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::ItemsController do
  before(:each) { create_and_login }

  describe 'GET /settings/items' do
    context 'with no kind' do
      it 'will redirect to asset kind' do
        get :index

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(items_kind_path('all'))
      end
    end

    context 'with a valid kind' do
      it 'will render all items' do
        get :index, params: { kind: 'all' }

        expect(response).to have_http_status(200)
      end

      it 'will render buy classified items' do
        get :index, params: { kind: 'buy' }

        expect(response).to have_http_status(200)
      end

      it 'will render sell classified items' do
        get :index, params: { kind: 'sell' }

        expect(response).to have_http_status(200)
      end
    end

    context 'with an invalid kind' do
      it 'will redirect to all items' do
        get :index, params: { kind: 'unknown_kind' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(items_kind_path('all'))
      end
    end
  end

  describe 'GET /settings/items/:id' do
    context 'with a valid identifier' do
      let(:item) { current_organization.items.create(name: 'Default', buy: false, sell: false) }

      it 'renders the view' do
        get :show, params: { id: item.id }

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

  describe 'GET /settings/items/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /settings/items/new_contextual' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new_contextual

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /settings/items' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          item: {
            name: 'Lightsaber Parts',
            buy: false,
            sell: false
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new item' do
        expect do
          post :create, params: {
            item: {
              name: 'Lightsaber Parts',
              buy: false,
              sell: false
            }
          }, format: :turbo_stream
        end.to change(Item, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            item: {
              name: 'Lightsaber Parts',
              buy: false,
              sell: false
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          item: {
            buy: true,
            sell: true
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new item' do
        expect do
          post :create, params: {
            item: {
              buy: true,
              sell: true
            }
          }, format: :html
        end.not_to change(Item, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            item: {
              buy: true,
              sell: true
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /settings/items/:id/edit' do
    context 'with a valid identifier' do
      let(:item) { current_organization.items.create(name: 'Default', buy: false, sell: false) }

      it 'renders the view' do
        get :edit, params: { id: item.id }

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

  describe 'PATCH /settings/items/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:item) { current_organization.items.create(name: 'Default', buy: false, sell: false) }

      it 'renders the view' do
        patch :update, params: { id: item.id, item: { name: 'Lightsaber Parts & Hilts' } }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the item' do
        item = current_organization.items.create(name: 'Default name')
        patch :update, params: { id: item.id, item: { name: 'Lightsaber Parts & Hilts' } }, format: :turbo_stream
        item.reload

        expect(item.name).to eq('Lightsaber Parts & Hilts')
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: item.id, item: {
              name: 'Lightsaber Parts & Hilts'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:item) { current_organization.items.create(name: 'Default', buy: false, sell: false) }

      it 'renders the view' do
        patch :update, params: { id: item.id, item: { buy: true, sell: true } }

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

  describe 'DELETE /settings/items/:id/edit' do
    context 'with a valid identifier' do
      it 'renders the view' do
        item = current_organization.items.create(name: 'Default name')

        delete :destroy, params: { id: item.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the item' do
        item = current_organization.items.create(name: 'Default name')

        expect { delete :destroy, params: { id: item.id }, format: :turbo_stream }.to change(Item, :count)
      end

      it 'creates an audit event' do
        item = current_organization.items.create(name: 'Default name')

        expect do
          delete :destroy, params: {
            id: item.id
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier but an item that cannot be deleted' do
      let(:contact) { FactoryBot.create(:contact, organization: current_organization) }
      let(:item) { current_organization.items.create(name: 'Default name') }
      before(:each) do
        cd = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        cd.lines.create(item:, account: current_organization.accounts.first)
      end

      it 'renders the view' do
        delete :destroy, params: { id: item.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not delete the item' do
        expect { delete :destroy, params: { id: item.id }, format: :turbo_stream }.not_to change(Item, :count)
      end

      it 'does not creates an audit event' do
        expect do
          delete :destroy, params: {
            id: item.id
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

      it 'does not eletes the item' do
        expect { delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream }.not_to change(Item, :count)
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

  describe 'DELETE /settings/items' do
    let(:contact) { FactoryBot.create(:contact, organization: current_organization) }

    context 'with valid ids' do
      it 'renders the view' do
        item_1 = current_organization.items.create(name: 'Default name 1')
        item_2 = current_organization.items.create(name: 'Default name 2')
        item_3 = current_organization.items.create(name: 'Default name 3')

        delete :destroy_many, params: {
          item_ids: [item_1.id, item_2.id, item_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the items' do
        item_1 = current_organization.items.create(name: 'Default name 1')
        item_2 = current_organization.items.create(name: 'Default name 2')
        item_3 = current_organization.items.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [item_1.id, item_2.id, item_3.id]
          }, format: :turbo_stream
        end.to change(Item, :count).by(-3)
      end

      it 'creates an audit event per item deleted' do
        item_1 = current_organization.items.create(name: 'Default name 1')
        item_2 = current_organization.items.create(name: 'Default name 2')
        item_3 = current_organization.items.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [item_1.id, item_2.id, item_3.id]
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

      it 'does not deletes the items' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(Item, :count)
      end

      it 'does not creates an audit event per item deleted' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end

    context 'with items that cannot be deleted' do
      it 'renders the view' do
        item_1 = current_organization.items.create(name: 'Default name')
        cd = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        cd.lines.create(item: item_1, account: current_organization.accounts.first)

        item_2 = current_organization.items.create(name: 'Default name')
        cd = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        cd.lines.create(item: item_2, account: current_organization.accounts.first)

        item_3 = current_organization.items.create(name: 'Default name')
        cd = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        cd.lines.create(item: item_3, account: current_organization.accounts.first)

        delete :destroy_many, params: {
          item_ids: [item_1.id, item_2.id, item_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not deletes the items' do
        item_1 = current_organization.items.create(name: 'Default name')
        cd = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        cd.lines.create(item: item_1, account: current_organization.accounts.first)

        item_2 = current_organization.items.create(name: 'Default name')
        cd = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        cd.lines.create(item: item_2, account: current_organization.accounts.first)

        item_3 = current_organization.items.create(name: 'Default name')
        cd = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        cd.lines.create(item: item_3, account: current_organization.accounts.first)

        expect do
          delete :destroy_many, params: {
            item_ids: [item_1.id, item_2.id, item_3.id]
          }, format: :turbo_stream
        end.not_to change(Item, :count)
      end

      it 'does not creates an audit event per item deleted' do
        item_1 = current_organization.items.create(name: 'Default name')
        cd = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        cd.lines.create(item: item_1, account: current_organization.accounts.first)

        item_2 = current_organization.items.create(name: 'Default name')
        cd = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        cd.lines.create(item: item_2, account: current_organization.accounts.first)

        item_3 = current_organization.items.create(name: 'Default name')
        cd = current_organization.commercial_documents.create(contact:, date: Date.today, type: 'Invoice')
        cd.lines.create(item: item_3, account: current_organization.accounts.first)

        expect do
          delete :destroy_many, params: {
            item_ids: [item_1.id, item_2.id, item_3.id]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
