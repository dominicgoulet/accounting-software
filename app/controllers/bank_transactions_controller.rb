# frozen_string_literal: true

class BankTransactionsController < ApplicationController
  before_action :set_bank_transactions

  def reset
    if @bank_transaction.reset
      ninetyfour_integration.log_event(@bank_transaction, 'update', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Bank transaction was resettedé'
          render partial: 'partials/flash'
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Could not reset bank transaction.'
          render partial: 'partials/flash', status: :unprocessable_entity
        end
      end
    end
  end

  def approve
    if @bank_transaction.approve
      ninetyfour_integration.log_event(@bank_transaction, 'update', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Bank transaction was resettedé'
          render partial: 'partials/flash'
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Could not reset bank transaction.'
          render partial: 'partials/flash', status: :unprocessable_entity
        end
      end
    end
  end

  def reject
    if @bank_transaction.reject
      ninetyfour_integration.log_event(@bank_transaction, 'update', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Bank transaction was resettedé'
          render partial: 'partials/flash'
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Could not reset bank transaction.'
          render partial: 'partials/flash', status: :unprocessable_entity
        end
      end
    end
  end

  def review
    if @bank_transaction.review
      ninetyfour_integration.log_event(@bank_transaction, 'update', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Bank transaction was resettedé'
          render partial: 'partials/flash'
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Could not reset bank transaction.'
          render partial: 'partials/flash', status: :unprocessable_entity
        end
      end
    end
  end

  def confirm_invoice_match
    if @bank_transaction.confirm_invoice_match(params[:invoice_id])
      ninetyfour_integration.log_event(@bank_transaction, 'update', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Bank transaction was resettedé'
          render partial: 'partials/flash'
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Could not reset bank transaction.'
          render partial: 'partials/flash', status: :unprocessable_entity
        end
      end
    end
  end

  def confirm_bill_match
    if @bank_transaction.confirm_bill_match(params[:bill_id])
      ninetyfour_integration.log_event(@bank_transaction, 'update', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Bank transaction was resettedé'
          render partial: 'partials/flash'
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Could not reset bank transaction.'
          render partial: 'partials/flash', status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_bank_transactions
    @bank_transaction = current_organization.bank_transactions.find_by(id: params[:id])
    @status = @bank_transaction.status

    @bank_account = @bank_transaction.bank_account
    @q = @bank_account.bank_transactions.where(status: @status).ransack(params[:q])
    @bank_transactions = @q.result.page(params[:page])
  end
end
