# frozen_string_literal: true

module Settings
  class UsersController < Settings::SettingsController
    before_action :set_user, only: %i[show edit update change_password security preferences cancel_change_email]

    def show; end

    def edit; end

    def change_password; end

    def update
      if can_update? && @user.update(user_params)
        ninetyfour_integration.log_event(@user, 'update', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'User updated successfully.'
            render partial: 'partials/flash'
          end
        end
      elsif params[:user][:password].present?
        render :change_password, status: :unprocessable_entity
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def cancel_change_email
      @user.cancel_change_email!

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'User updated successfully.'
          render partial: 'partials/flash'
        end
      end
    end

    private

    def set_user
      @user = current_organization.users.find(params[:id])
      @user = nil unless @user.id == current_user.id
    end

    def user_params
      params[:user].permit(
        :first_name,
        :last_name,
        :password
      )
    end

    def can_update?
      return false if params[:user][:password].present? && !@user.can_update_password?(params[:user][:current_password])

      if params[:user][:email].present? && params[:user][:email] != @user.email
        return false if User.find_by(email: params[:user][:email]).present?

        return false unless @user.change_email!(params[:user][:email])

        params[:user].delete(:email)

      end

      true
    end
  end
end
