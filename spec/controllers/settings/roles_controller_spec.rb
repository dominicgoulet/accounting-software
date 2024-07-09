# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::RolesController do
  before(:each) { create_and_login }

  describe 'GET /settings/roles' do
    context 'with valid information' do
      it 'will render all roles' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /settings/roles/:id' do
    context 'with a valid identifier' do
      let(:role) { current_organization.roles.create(name: 'Default') }

      it 'renders the view' do
        get :show, params: { id: role.id }

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

  describe 'GET /settings/roles/new' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /settings/roles/new_contextual' do
    context 'with valid parameters' do
      it 'renders the view' do
        get :new_contextual

        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /settings/roles' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create, params: {
          role: {
            name: 'The Jedis'
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new role' do
        expect do
          post :create, params: {
            role: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(Role, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            role: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with invalid parameters' do
      it 'does not returns a valid http code' do
        post :create, params: {
          role: {
            name: ''
          }
        }, format: :html

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new role' do
        expect do
          post :create, params: {
            role: {
              name: ''
            }
          }, format: :html
        end.not_to change(Role, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            role: {
              name: ''
            }
          }, format: :html
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'GET /settings/roles/:id/edit' do
    context 'with a valid identifier' do
      let(:role) { current_organization.roles.create(name: 'Default') }

      it 'renders the view' do
        get :edit, params: { id: role.id }

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

  describe 'PATCH /settings/roles/:id/edit' do
    context 'with a valid identifier and valid parameters' do
      let(:role) { current_organization.roles.create(name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: role.id, role: { name: 'The Jedis' } }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'updates the role' do
        role = current_organization.roles.create(name: 'Default name')
        patch :update, params: { id: role.id, role: { name: 'The Jedis' } }, format: :turbo_stream
        role.reload

        expect(role.name).to eq('The Jedis')
      end

      it 'creates an audit event' do
        expect do
          patch :update, params: {
            id: role.id, role: {
              name: 'The Jedis'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier and invalid parameters' do
      let(:role) { current_organization.roles.create(name: 'Default') }

      it 'renders the view' do
        patch :update, params: { id: role.id, role: { name: '' } }

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

  describe 'DELETE /settings/roles/:id' do
    context 'with a valid identifier' do
      it 'renders the view' do
        role = current_organization.roles.create(name: 'Default name')

        delete :destroy, params: { id: role.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the role' do
        role = current_organization.roles.create(name: 'Default name')

        expect { delete :destroy, params: { id: role.id }, format: :turbo_stream }.to change(Role, :count)
      end

      it 'creates an audit event' do
        role = current_organization.roles.create(name: 'Default name')

        expect do
          delete :destroy, params: {
            id: role.id
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

      it 'does not eletes the role' do
        expect { delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream }.not_to change(Role, :count)
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

  describe 'DELETE /settings/roles' do
    context 'with valid ids' do
      it 'renders the view' do
        role_1 = current_organization.roles.create(name: 'Default name 1')
        role_2 = current_organization.roles.create(name: 'Default name 2')
        role_3 = current_organization.roles.create(name: 'Default name 3')

        delete :destroy_many, params: {
          item_ids: [role_1.id, role_2.id, role_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the roles' do
        role_1 = current_organization.roles.create(name: 'Default name 1')
        role_2 = current_organization.roles.create(name: 'Default name 2')
        role_3 = current_organization.roles.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [role_1.id, role_2.id, role_3.id]
          }, format: :turbo_stream
        end.to change(Role, :count).by(-3)
      end

      it 'creates an audit event per role deleted' do
        role_1 = current_organization.roles.create(name: 'Default name 1')
        role_2 = current_organization.roles.create(name: 'Default name 2')
        role_3 = current_organization.roles.create(name: 'Default name 3')

        expect do
          delete :destroy_many, params: {
            item_ids: [role_1.id, role_2.id, role_3.id]
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

      it 'does not deletes the roles' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(Role, :count)
      end

      it 'does not creates an audit event per role deleted' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
