# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController do
  it 'GET /sign_in when not signed_in?' do
    user = create_and_login
    expect(request.session[:user_id]).not_to be_nil

    get :new

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(root_path)
  end

  it 'GET /sign_in when signed_in?' do
    get :new

    expect(response).to have_http_status(200)
    expect(request.session[:user_id]).to be_nil
  end

  it 'POST /sign_in with valid credentials' do
    FactoryBot.create(:user, email: 'test@test.org', password: '0000')

    post :create, params: { user: { email: 'test@test.org', password: '0000' } }

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(root_path)
    expect(request.session[:user_id]).not_to be_nil
  end

  it 'POST /sign_in with invalid credentials' do
    FactoryBot.create(:user, email: 'test@test.org', password: '0000')

    post :create, params: { user: { email: 'test_invalid@test.org', password: '0000_invalid' } }

    expect(response).to have_http_status(422)
    expect(request.session[:user_id]).to be_nil
  end

  it 'POST /sign_in with invalid parameters' do
    FactoryBot.create(:user, email: 'test@test.org', password: '0000')

    post :create

    expect(response).to have_http_status(422)
    expect(request.session[:user_id]).to be_nil
  end

  it 'DELETE /sign_out when signed_in?' do
    user = create_and_login
    expect(request.session[:user_id]).not_to be_nil

    delete :destroy

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(root_path)
    expect(request.session[:user_id]).to be_nil
  end

  it 'DELETE /sign_out when not signed_in?' do
    expect(request.session[:user_id]).to be_nil

    delete :destroy

    expect(response).to have_http_status(302)
    expect(response).to redirect_to(sign_in_path)
    expect(request.session[:user_id]).to be_nil
  end
end
