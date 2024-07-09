# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::PermissionsController do
  before(:each) { create_and_login }

  describe 'PATCH /settings/permissions/:id/permission_level_none' do
    context 'with a valid identifier and valid parameters' do
      let(:permission) { FactoryBot.create(:permission, organization: current_organization) }

      it 'returns json success' do
        patch :permission_level_none, params: { id: permission.id }

        expect(response).to have_http_status(200)
      end

      it 'updates the role' do
        patch :permission_level_none, params: { id: permission.id }
        permission.reload

        expect(permission.level).to eq('none')
      end

      it 'creates an audit event' do
        expect do
          patch :permission_level_none, params: {
            id: permission.id
          }
        end.to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        patch :permission_level_none, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /settings/permissions/:id/permission_level_view' do
    context 'with a valid identifier and valid parameters' do
      let(:permission) { FactoryBot.create(:permission, organization: current_organization) }

      it 'returns json success' do
        patch :permission_level_view, params: { id: permission.id }

        expect(response).to have_http_status(200)
      end

      it 'updates the role' do
        patch :permission_level_view, params: { id: permission.id }
        permission.reload

        expect(permission.level).to eq('view')
      end

      it 'creates an audit event' do
        expect do
          patch :permission_level_view, params: {
            id: permission.id
          }
        end.to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        patch :permission_level_view, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /settings/permissions/:id/permission_level_edit' do
    context 'with a valid identifier and valid parameters' do
      let(:permission) { FactoryBot.create(:permission, organization: current_organization) }

      it 'returns json success' do
        patch :permission_level_edit, params: { id: permission.id }

        expect(response).to have_http_status(200)
      end

      it 'updates the role' do
        patch :permission_level_edit, params: { id: permission.id }
        permission.reload

        expect(permission.level).to eq('edit')
      end

      it 'creates an audit event' do
        expect do
          patch :permission_level_edit, params: {
            id: permission.id
          }
        end.to change(AuditEvent, :count)
      end
    end

    context 'with an invalid identifier' do
      it 'redirects after handling the error' do
        patch :permission_level_edit, params: { id: 'invalid-id' }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
