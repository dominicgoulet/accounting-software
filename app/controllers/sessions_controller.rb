# frozen_string_literal: true

class SessionsController < ApplicationController
  layout 'public'

  def new
    redirect_to root_path if signed_in?

    @user = User.new
  end

  def create
    if signed_in?
      redirect_to root_path
    elsif params[:user].present?
      @user = User.authenticate_with_email_and_password(
        params[:user][:email],
        params[:user][:password],
        request.remote_ip
      )

      if @user.present?
        sign_in!(@user)
      else
        @user = User.new(email: params[:user][:email])

        handle_sign_in_error
      end
    else
      handle_sign_in_error
    end
  end

  def destroy
    redirect_to root_path unless signed_in?

    sign_out!
  end

  private

  def handle_sign_in_error
    flash.now.alert = 'Invalid email/password combination.'
    render :new, status: :unprocessable_entity
  end
end
