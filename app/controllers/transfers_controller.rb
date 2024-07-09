# frozen_string_literal: true

class TransfersController < ApplicationController
  before_action :ensure_frame_response, only: %i[new edit]
  before_action :set_transfer, only: %i[show edit update destroy]

  def index
    @q = current_organization.transfers.ransack(params[:q])
    @transfers = @q.result
  end

  def show; end

  # GET /transfers/new
  def new
    @transfer = Transfer.new(date: Date.today)
  end

  # POST /transfers
  def create
    @transfer = current_organization.transfers.build(transfer_params)

    if @transfer.save
      ninetyfour_integration.log_event(@transfer, 'create', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Transfer created successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /transfers/1/edit
  def edit; end

  # PATCH /transfers/1
  def update
    if @transfer.update(transfer_params)
      ninetyfour_integration.log_event(@transfer, 'update', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Transfer updated successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /transfers/1
  def destroy
    if @transfer.destroy
      ninetyfour_integration.log_event(@transfer, 'destroy', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Transfer deleted successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Transfer could not be deleted.'
          render partial: 'partials/flash'
        end
      end
    end
  end

  def destroy_many
    @items = current_organization.transfers.where(id: params[:item_ids])
    destroyed_count = 0

    @items.each do |item|
      if item.destroy
        ninetyfour_integration.log_event(item, 'destroy', current_user)
        destroyed_count += 1
      end
    end

    respond_to do |format|
      format.turbo_stream do
        flash.now.notice = "#{destroyed_count} transfers out of #{@items.size} were successfully deleted."
        render partial: 'partials/flash'
      end
    end
  end

  private

  def set_transfer
    @transfer = current_organization.transfers.find(params[:id])
  end

  def transfer_params
    params[:transfer]&.permit(
      :to_account_id,
      :from_account_id,
      :date,
      :amount,
      :note,
      attached_files: []
    )
  end
end
