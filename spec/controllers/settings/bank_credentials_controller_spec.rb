# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::BankCredentialsController do
  before(:each) { create_and_login }

  describe 'GET /settings/bank_crendetials' do
    context 'with valid information' do
      it 'will render all bank_crendetials' do
        get :index

        expect(response).to have_http_status(200)
      end
    end
  end
end
