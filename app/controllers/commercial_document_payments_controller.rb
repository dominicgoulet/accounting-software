# frozen_string_literal: true

class CommercialDocumentPaymentsController < ApplicationController
  before_action :ensure_frame_response, only: %i[new edit]
  before_action :set_commercial_document
  before_action :set_payment, only: %i[edit update destroy]

  def new
    @payment = @commercial_document.payments.build(date: Date.today, amount: @commercial_document.amount_due)
  end

  # POST /payments
  def create
    @payment = @commercial_document.payments.build(payment_params)
    @payment.organization = current_organization

    if @payment.save
      ninetyfour_integration.log_event(@payment, 'create', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Payment created successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  # PATCH /payments/1
  def update
    if @payment.update(payment_params)
      ninetyfour_integration.log_event(@payment, 'update', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Payment updated successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /payments/1
  def destroy
    if @payment.destroy
      ninetyfour_integration.log_event(@payment, 'destroy', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Payment deleted successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Payment could not be deleted.'
          render partial: 'partials/flash'
        end
      end
    end
  end

  private

  def set_commercial_document
    @commercial_document = current_organization.commercial_documents.find(params["#{params[:type].underscore.downcase}_id"])
  end

  def set_payment
    @payment = current_organization.payments.find(params[:id])
  end

  def payment_params
    params[:payment]&.permit(
      :account_id,
      :date,
      :amount,
      attached_files: []
    )
  end
end
