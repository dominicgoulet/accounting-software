# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PasswordsController do
  it 'GET /forgot_password when signed_in?' do
    user = create_and_login

    get :new

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(root_path)
  end

  it 'GET /forgot_password when not signed_in?' do
    get :new

    expect(response).to have_http_status(200)
  end

  it 'POST /forgot_password when signed_in?' do
    user = create_and_login

    post :create, params: { user: { email: 'test@test.org' } }

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(root_path)
  end

  it 'POST /forgot_password with valid params' do
    FactoryBot.create(:user, email: 'test@test.org')

    post :create, params: { user: { email: 'test@test.org' } }

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(forgot_password_path)
  end

  it 'POST /forgot_password with invalid params' do
    FactoryBot.create(:user, email: 'test@test.org')

    post :create, params: { user: { email: 'test_invalid@test.org' } }

    expect(response).to have_http_status(422)
  end

  it 'POST /forgot_password with invalid parameter structure' do
    post :create

    expect(response.status).to eq(422)
  end
end
