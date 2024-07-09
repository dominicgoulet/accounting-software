# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::IntegrationsController do
  before(:each) { create_and_login }

  describe 'GET /settings/integrations' do
    context 'with valid information' do
      it 'will render all integrations' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /settings/integrations/:id' do
    context 'with a valid identifier' do
      let(:integration) { current_organization.integrations.create(name: 'Default') }

      it 'renders the view' do
        get :show, params: { id: integration.id }

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

  describe 'GET /settings/integrations/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /settings/integrations/new_contextual' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new_contextual

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /settings/integrations' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          integration: {
            name: 'The Jedis'
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new integration' do
        expect do
          post :create, params: {
            integration: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(Integration, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            integration: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          integration: {
            name: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new integration' do
        expect do
          post :create, params: {
            integration: {
              name: ''
            }
          }, format: :html
        end.not_to change(Integration, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            integration: {
              name: ''
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /settings/integrations/:id/edit' do
    context 'with a valid identifier' do
      let(:integration) { current_organization.integrations.create(name: 'Default') }

      it 'renders the view' do
        get :edit, params: { id: integration.id }

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

  describe 'PATCH /settings/integrations/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:integration) { current_organization.integrations.create(name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: integration.id, integration: { name: 'The Jedis' } }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the integration' do
        integration = current_organization.integrations.create(name: 'Default name')
        patch :update, params: { id: integration.id, integration: { name: 'The Jedis' } }, format: :turbo_stream
        integration.reload

        expect(integration.name).to eq('The Jedis')
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: integration.id, integration: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:integration) { current_organization.integrations.create(name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: integration.id, integration: { name: '' } }

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

  describe 'DELETE /settings/integrations/:id/edit' do
    context 'with a valid identifier' do
      it 'renders the view' do
        integration = current_organization.integrations.create(name: 'Default name')

        delete :destroy, params: { id: integration.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the integration' do
        integration = current_organization.integrations.create(name: 'Default name')

        expect { delete :destroy, params: { id: integration.id }, format: :turbo_stream }.to change(Integration, :count)
      end

      it 'creates an audit event' do
        integration = current_organization.integrations.create(name: 'Default name')

        expect do
          delete :destroy, params: {
            id: integration.id
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

      it 'does not eletes the integration' do
        expect do
          delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream
        end.not_to change(Integration, :count)
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

  describe 'DELETE /settings/integrations' do
    context 'with valid ids' do
      it 'renders the view' do
        integration_1 = current_organization.integrations.create(name: 'Default name 1')
        integration_2 = current_organization.integrations.create(name: 'Default name 2')
        integration_3 = current_organization.integrations.create(name: 'Default name 3')

        delete :destroy_many, params: {
          item_ids: [integration_1.id, integration_2.id, integration_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the integrations' do
        integration_1 = current_organization.integrations.create(name: 'Default name 1')
        integration_2 = current_organization.integrations.create(name: 'Default name 2')
        integration_3 = current_organization.integrations.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [integration_1.id, integration_2.id, integration_3.id]
          }, format: :turbo_stream
        end.to change(Integration, :count).by(-3)
      end

      it 'creates an audit event per integration deleted' do
        integration_1 = current_organization.integrations.create(name: 'Default name 1')
        integration_2 = current_organization.integrations.create(name: 'Default name 2')
        integration_3 = current_organization.integrations.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [integration_1.id, integration_2.id, integration_3.id]
          }, format: :turbo_stream
        end.to change(AuditEvent, :count).by(3)
      end
    end

    context 'with a valid identifier but an integration that cannot be deleted' do
      let(:integration) { current_organization.integrations.create(name: 'Default name', system: true) }

      it 'renders the view' do
        delete :destroy, params: { id: integration.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not delete the integration' do
        expect { delete :destroy, params: { id: integration.id }, format: :turbo_stream }.not_to change(Item, :count)
      end

      it 'does not creates an audit event' do
        expect do
          delete :destroy, params: {
            id: integration.id
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end

    context 'with invalid ids' do
      it 'renders the view' do
        delete :destroy_many, params: {
          item_ids: %w[invalid-id-1 invalid-id-2]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not deletes the integrations' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(Integration, :count)
      end

      it 'does not creates an audit event per integration deleted' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end

    context 'with integrations that cannot be deleted' do
      it 'renders the view' do
        integration_1 = current_organization.integrations.create(name: 'Default name', system: true)
        integration_2 = current_organization.integrations.create(name: 'Default name', system: true)
        integration_3 = current_organization.integrations.create(name: 'Default name', system: true)

        delete :destroy_many, params: {
          item_ids: [integration_1.id, integration_2.id, integration_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not deletes the integrations' do
        integration_1 = current_organization.integrations.create(name: 'Default name', system: true)
        integration_2 = current_organization.integrations.create(name: 'Default name', system: true)
        integration_3 = current_organization.integrations.create(name: 'Default name', system: true)

        expect do
          delete :destroy_many, params: {
            item_ids: [integration_1.id, integration_2.id, integration_3.id]
          }, format: :turbo_stream
        end.not_to change(Item, :count)
      end

      it 'does not creates an audit event per integration deleted' do
        integration_1 = current_organization.integrations.create(name: 'Default name', system: true)
        integration_2 = current_organization.integrations.create(name: 'Default name', system: true)
        integration_3 = current_organization.integrations.create(name: 'Default name', system: true)

        expect do
          delete :destroy_many, params: {
            item_ids: [integration_1.id, integration_2.id, integration_3.id]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
