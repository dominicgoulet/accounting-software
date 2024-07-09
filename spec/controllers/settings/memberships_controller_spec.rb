# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::MembershipsController do
  before(:each) { create_and_login }

  describe 'POST /settings/memberships' do
    context 'with valid email that is not a member' do
      it 'returns a valid http code' do
        post :create, params: {
          membership: {
            email: 'darth.vader@theempire.com'
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'creates a new membership' do
        expect do
          post :create, params: {
            membership: {
              email: 'darth.vader@theempire.com'
            }
          }, format: :turbo_stream
        end.to change(Membership, :count)
      end

      it 'creates an audit event' do
        expect do
          post :create, params: {
            membership: {
              email: 'darth.vader@theempire.com'
            }
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with valid email that is a member' do
      it 'returns a valid http code' do
        post :create, params: {
          membership: {
            email: current_user.email
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'does not creates a new membership' do
        expect do
          post :create, params: {
            membership: {
              email: current_user.email
            }
          }, format: :turbo_stream
        end.not_to change(Membership, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            membership: {
              email: current_user.email
            }
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end

    context 'with invalid email' do
      it 'does not returns a valid http code' do
        post :create, params: {
          membership: {
            email: 'invalid-email'
          }
        }, format: :turbo_stream

        expect(response).to have_http_status(422)
      end

      it 'does not creates a new membership' do
        expect do
          post :create, params: {
            membership: {
              email: 'invalid-email'
            }
          }, format: :turbo_stream
        end.not_to change(Membership, :count)
      end

      it 'does not creates an audit event' do
        expect do
          post :create, params: {
            membership: {
              email: 'invalid-email'
            }
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end

  describe 'PATCH /settings/memberships/:id/promote' do
    context 'with a valid identifier and valid parameters' do
      let(:membership) { FactoryBot.create(:membership, organization: current_organization) }

      it 'returns json success' do
        patch :promote, params: { id: membership.id }

        expect(response).to have_http_status(200)
      end

      it 'updates the membership' do
        patch :promote, params: { id: membership.id }
        membership.reload

        expect(membership.level).to eq('admin')
      end

      it 'creates an audit event' do
        expect do
          patch :promote, params: {
            id: membership.id
          }
        end.to change(AuditEvent, :count)
      end
    end
  end

  describe 'PATCH /settings/memberships/:id/demote' do
    context 'with a valid identifier and valid parameters' do
      let(:membership) { FactoryBot.create(:membership, organization: current_organization) }

      it 'returns json success' do
        patch :demote, params: { id: membership.id }

        expect(response).to have_http_status(200)
      end

      it 'updates the membership' do
        patch :demote, params: { id: membership.id }
        membership.reload

        expect(membership.level).to eq('member')
      end

      it 'creates an audit event' do
        expect do
          patch :demote, params: {
            id: membership.id
          }
        end.to change(AuditEvent, :count)
      end
    end
  end

  describe 'DELETE /settings/memberships/:id/edit' do
    context 'with a valid identifier' do
      it 'renders the view' do
        membership = FactoryBot.create(:membership, organization: current_organization)

        delete :destroy, params: { id: membership.id }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the membership' do
        membership = FactoryBot.create(:membership, organization: current_organization)

        expect { delete :destroy, params: { id: membership.id }, format: :turbo_stream }.to change(Membership, :count)
      end

      it 'creates an audit event' do
        membership = FactoryBot.create(:membership, organization: current_organization)

        expect do
          delete :destroy, params: {
            id: membership.id
          }, format: :turbo_stream
        end.to change(AuditEvent, :count)
      end
    end

    context 'with a valid identifier that cannot be deleted' do
      it 'renders the view' do
        delete :destroy, params: { id: current_user.memberships.first.id }, format: :turbo_stream

        expect(response).to have_http_status(422)
      end

      it 'does not deletes the membership' do
        expect do
          delete :destroy, params: { id: current_user.memberships.first.id },
                           format: :turbo_stream
        end.not_to change(Membership, :count)
      end

      it 'does not creates an audit event' do
        expect do
          delete :destroy, params: {
            id: current_user.memberships.first.id
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

      it 'does not eletes the membership' do
        expect do
          delete :destroy, params: { id: 'invalid-id' }, format: :turbo_stream
        end.not_to change(Membership, :count)
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

  describe 'DELETE /settings/memberships' do
    context 'with valid ids' do
      it 'renders the view' do
        membership_1 = FactoryBot.create(:membership, organization: current_organization)
        membership_2 = FactoryBot.create(:membership, organization: current_organization)
        membership_3 = FactoryBot.create(:membership, organization: current_organization)

        delete :destroy_many, params: {
          item_ids: [membership_1.id, membership_2.id, membership_3.id]
        }, format: :turbo_stream

        expect(response).to have_http_status(200)
      end

      it 'deletes the memberships' do
        membership_1 = FactoryBot.create(:membership, organization: current_organization)
        membership_2 = FactoryBot.create(:membership, organization: current_organization)
        membership_3 = FactoryBot.create(:membership, organization: current_organization)

        expect do
          delete :destroy_many, params: {
            item_ids: [membership_1.id, membership_2.id, membership_3.id]
          }, format: :turbo_stream
        end.to change(Membership, :count).by(-3)
      end

      it 'creates an audit event per membership deleted' do
        membership_1 = FactoryBot.create(:membership, organization: current_organization)
        membership_2 = FactoryBot.create(:membership, organization: current_organization)
        membership_3 = FactoryBot.create(:membership, organization: current_organization)

        expect do
          delete :destroy_many, params: {
            item_ids: [membership_1.id, membership_2.id, membership_3.id]
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

      it 'does not deletes the memberships' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(Membership, :count)
      end

      it 'does not creates an audit event per membership deleted' do
        expect do
          delete :destroy_many, params: {
            item_ids: %w[invalid-id-1 invalid-id-2]
          }, format: :turbo_stream
        end.not_to change(AuditEvent, :count)
      end
    end
  end
end
