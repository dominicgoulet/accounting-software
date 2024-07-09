# frozen_string_literal: true

class JournalEntriesController < ApplicationController
  before_action :ensure_frame_response, only: %i[new edit]
  before_action :set_journal_entry, only: %i[show edit update destroy]

  def index
    @journalable_type = params[:journalable_type]
    @integration_id = params[:integration_id]

    @q = current_organization.journal_entries
    @q = @q.where(integration_id: @integration_id) if @integration_id.present?
    @q = @q.where(journalable_type: @journalable_type) if @journalable_type.present?
    @q = @q.ransack(params[:q])

    @journal_entries = @q.result.page params[:page]
  end

  # GET /journal_entries/1
  def show; end

  # GET /journal_entries/new
  def new
    @journal_entry = JournalEntry.new(date: Date.today)
  end

  # POST /journal_entries
  def create
    @journal_entry = current_organization.journal_entries.build(journal_entry_params)
    @journal_entry.integration = ninetyfour_integration
    @journal_entry.journalable = @journal_entry

    if @journal_entry.save
      ninetyfour_integration.log_event(@journal_entry, 'create', current_user)

      if params[:recurring_event].present?
        @journal_entry.setup_recurring_event! params[:recurring_event][:enabled], recurring_event_params
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Journal entry created successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /journal_entries/1/edit
  def edit; end

  # PATCH /journal_entries/1
  def update
    if @journal_entry.update(journal_entry_params)
      ninetyfour_integration.log_event(@journal_entry, 'update', current_user)

      if params[:recurring_event].present?
        @journal_entry.setup_recurring_event! params[:recurring_event][:enabled], recurring_event_params
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Journal entry updated successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /journal_entries/1
  def destroy
    if @journal_entry.destroy
      ninetyfour_integration.log_event(@journal_entry, 'destroy', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Journal entry deleted successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Journal entry could not be deleted.'
          render partial: 'partials/flash'
        end
      end
    end
  end

  def destroy_many
    @items = current_organization.journal_entries.where(id: params[:item_ids])
    destroyed_count = 0

    @items.each do |item|
      if item.destroy
        ninetyfour_integration.log_event(item, 'destroy', current_user)
        destroyed_count += 1
      end
    end

    respond_to do |format|
      format.turbo_stream do
        flash.now.notice = "#{destroyed_count} journal entries out of #{@items.size} were successfully deleted."
        render partial: 'partials/flash'
      end
    end
  end

  private

  def set_journal_entry
    @journal_entry = current_organization.journal_entries.find(params[:id])
  end

  def journal_entry_params
    params[:journal_entry]&.permit(
      :contact_id,
      :date,
      :narration,
      journal_entry_lines_attributes: %i[
        id
        account_id
        contact_id
        business_unit_id
        credit
        debit
        _destroy
      ],
      attached_files: []
    )
  end
end
