# frozen_string_literal: true

class BankingController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def create_link_token
    @link_token = Banking.get_link_token(current_organization.id)
    render json: { link_token: @link_token }
  end

  def update_link_token
    @bank_credential = current_organization.bank_credentials.find(params[:id])
    @link_token = Banking.update_link_token(current_organization.id, @bank_credential.access_token)
    render json: { link_token: @link_token }
  end

  def exchange_public_token
    @bank_credential = current_organization.bank_credentials.find_or_create_by(
      access_token: Banking.get_access_token(bank_credential_params[:public_token])
    )

    @bank_credential.public_token = bank_credential_params[:public_token]

    @bank_credential.status = 'ok'
    @bank_credential.error_type = nil
    @bank_credential.error_code = nil

    if @bank_credential.save
      render json: { success: true }, status: :ok
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  private

  def bank_credential_params
    params.permit(
      :link_token,
      :public_token
    )
  end
end
