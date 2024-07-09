# frozen_string_literal: true

class PasswordsController < ApplicationController
  layout 'public'

  def new
    redirect_to root_path if signed_in?

    @user = User.new
  end

  def create
    if signed_in?
      redirect_to root_path
    elsif params[:user].present?
      @user = User.find_by(email: params[:user][:email])

      if @user.present?
        @user.send_reset_password_instructions!

        flash.now.alert = 'We just send you an email with the instructions.'
        redirect_to forgot_password_path
      else
        @user = User.new(email: params[:user][:email])

        handle_password_reset_error
      end
    else
      handle_password_reset_error
    end
  end

  def edit
    if signed_in?
      redirect_to root_path
    else
      return if User.find_by(reset_password_token: params[:reset_token])

      redirect_to forgot_password_path, alert: 'Invalid password reset link.'
    end
  end

  # PATCH /passwords/:reset_token
  def update
    if signed_in?
      redirect_to root_path
    else
      @user = User.reset_password_with_token!(params[:reset_token], params[:password])

      if @user.present?
        sign_in!(@user)
      else
        flash.now.alert = 'We could not reset your password. Please contact support@ninetyfour.io for further help.'
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def handle_password_reset_error
    flash.now.alert = 'We could not find an account registered with this email.'
    render :new, status: :unprocessable_entity
  end
end
