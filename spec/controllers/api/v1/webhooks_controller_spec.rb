# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::WebhooksController do
  describe 'POST /webhooks' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :create

        expect(response).to have_http_status(204)
      end
    end
  end
end
