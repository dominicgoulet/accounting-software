# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController do
  it 'GET /sign_up when signed_in?' do
    user = create_and_login

    get :new

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(root_path)
  end

  it 'GET /sign_up when not signed_in?' do
    get :new

    expect(response).to have_http_status(200)
  end

  it 'POST /sign_up when signed_in?' do
    user = create_and_login

    post :create, params: { user: { email: 'test@test.org', password: '0000' } }

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(root_path)
  end

  it 'POST /sign_up with valid params' do
    post :create, params: { user: { email: 'test@test.org', password: '0000' } }

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(root_path)
  end

  it 'POST /sign_up with existing user params' do
    FactoryBot.create(:user, email: 'test@test.org', password: '0000')

    post :create, params: { user: { email: 'test@test.org', password: '0000' } }

    expect(response).to have_http_status(422)
  end

  it 'POST /sign_up with invalid parameters' do
    post :create

    expect(response).to have_http_status(422)
  end
end
