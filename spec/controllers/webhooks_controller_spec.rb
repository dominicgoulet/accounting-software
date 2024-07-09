# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebhooksController do
  describe 'POST /webhooks/plaid' do
    context 'with valid parameters' do
      it 'returns a valid http code' do
        post :plaid

        expect(response).to have_http_status(204)
      end
    end
  end
end
