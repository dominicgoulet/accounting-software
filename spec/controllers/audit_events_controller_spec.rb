# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditEventsController do
  before(:each) { create_and_login }

  describe 'GET /audit_trail' do
    context 'with valid information' do
      it 'will render all audit_events' do
        get :index, params: { auditable_type: 'Organization', auditable_id: current_organization.id }

        expect(response).to have_http_status(200)
      end
    end
  end
end
