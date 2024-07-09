# frozen_string_literal: true

class TransactionsController < ApplicationController
  def index
    unless current_organization.bank_credentials.size.positive? && current_organization.bank_accounts.size.positive?
      redirect_to bank_credentials_path
    end

    @bank_accounts = current_organization.bank_accounts.order(:name)

    @bank_account = current_organization.bank_accounts.find_by(id: params[:bank_account_id]) || @bank_accounts.first
    @bank_transactions = @bank_account&.bank_transactions

    redirect_to bank_account_transactions_path if params[:bank_account_id].present? && @bank_account.nil?
  end

  def all
    @bank_accounts = current_organization.bank_accounts.order(:name)

    @bank_account = current_organization.bank_accounts.find_by(id: params[:bank_account_id]) || @bank_accounts.first
    @q = @bank_account&.bank_transactions&.ransack(params[:q])
    @bank_transactions = @q.result

    redirect_to all_bank_account_transactions_path if params[:bank_account_id].present? && @bank_account.nil?
  end
end
