# frozen_string_literal: true

class RegistrationsController < ApplicationController
  layout 'public'

  def new
    redirect_to root_path if signed_in?

    @user = User.new
  end

  def create
    if signed_in?
      redirect_to root_path
    else
      @user = User.new(user_params)

      if @user.save
        sign_in!(@user)
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params[:user]&.permit(
      :email,
      :password
    )
  end
end
