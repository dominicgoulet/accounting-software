# frozen_string_literal: true

module AuthHelpers
  def authenticate(integration)
    request.headers['Authorization'] = "Token token=#{integration.secret_key}"
  end

  def create_and_login
    user = FactoryBot.create(:user)
    user.current_organization.setup_completed!
    request.session[:user_id] = user.id

    user
  end

  def current_user
    User.find(request.session[:user_id])
  end

  def current_organization
    current_user.current_organization
  end
end
