# frozen_string_literal: true

class CommercialDocumentsController < ApplicationController
  layout 'documents'
  before_action :ensure_frame_response, only: %i[new edit]
  before_action :set_document, except: %i[index archives new create destroy_many]

  def index
    @status = params[:status]

    @q = current_organization.commercial_documents.where(type: params[:type])
    @q = @q.where(status: params[:status]) if @status.present?
    @q = @q.ransack(params[:q])

    @commercial_documents = @q.result
  end

  def archives
    @status = params[:status]

    @q = current_organization.commercial_documents.where(type: params[:type])

    @q = @q.where(status: params[:status]) if @status.present?

    @q = @q.ransack(params[:q])

    @commercial_documents = @q.result
  end

  def show; end

  def new
    @commercial_document = params[:type].constantize.new(date: Date.today)
  end

  def create
    build_params = (document_params || {}).merge(type: params[:type])
    @commercial_document = current_organization.commercial_documents.build(build_params)

    if @commercial_document.save
      ninetyfour_integration.log_event(@commercial_document, 'create', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = "#{params[:type]} created successfully."
          render partial: 'partials/flash'
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @commercial_document.update(document_params)
      ninetyfour_integration.log_event(@commercial_document, 'update', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = "#{document_name.camelize} updated successfully."
          render partial: 'partials/flash'
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def accept_draft
    respond_to do |format|
      if @commercial_document.accept_draft!
        ninetyfour_integration.log_event(@commercial_document, 'update', current_user)

        format.turbo_stream do
          flash.now.notice = 'Draft accepted.'
          render partial: 'partials/flash'
        end
      else
        format.turbo_stream do
          flash.now.notice = 'Could not accept draft.'
          render partial: 'partials/flash'
        end
      end
    end
  end

  def mark_as_sent
    respond_to do |format|
      if @commercial_document.mark_as_sent!
        ninetyfour_integration.log_event(@commercial_document, 'update', current_user)

        format.turbo_stream do
          flash.now.notice = 'Marked as sent.'
          render partial: 'partials/flash'
        end
      else
        format.turbo_stream do
          flash.now.notice = 'Could not mark as sent.'
          render partial: 'partials/flash'
        end
      end
    end
  end

  def return_to_draft
    respond_to do |format|
      if @commercial_document.return_to_draft!
        ninetyfour_integration.log_event(@commercial_document, 'update', current_user)

        format.turbo_stream do
          flash.now.notice = 'Marked as draft.'
          render partial: 'partials/flash'
        end
      else
        format.turbo_stream do
          flash.now.notice = 'Could not return to draft.'
          render partial: 'partials/flash'
        end
      end
    end
  end

  def prepare_email
    @email = OutgoingEmail.new(related_object: @commercial_document)
  end

  def send_email
    @email = current_organization.outgoing_emails.build(outgoing_email_params)
    @email.recipients = outgoing_email_recipients_params
    @email.related_object = @commercial_document

    if @email.save
      ninetyfour_integration.log_event(@email, 'create', current_user)

      @email.send!
      @commercial_document.mark_as_sent!

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Invoice successfully sent by email.'
          render partial: 'partials/flash'
        end
      end
    else
      render :prepare_email, status: :unprocessable_entity
    end
  end

  def destroy
    if @commercial_document.destroy
      ninetyfour_integration.log_event(@commercial_document, 'destroy', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = "#{document_name.camelize} deleted successfully."
          render partial: 'partials/flash'
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = "#{document_name.camelize} could not be deleted."
          render partial: 'partials/flash'
        end
      end
    end
  end

  def destroy_many
    @items = current_organization.commercial_documents.where(id: params[:item_ids])
    destroyed_count = 0

    @items.each do |item|
      if item.destroy
        ninetyfour_integration.log_event(item, 'destroy', current_user)
        destroyed_count += 1
      end
    end

    respond_to do |format|
      format.turbo_stream do
        flash.now.notice = "#{destroyed_count} #{document_name.pluralize} out of #{@items.size} were successfully deleted."
        render partial: 'partials/flash'
      end
    end
  end

  private

  def document_name
    params[:type].downcase
  end

  def set_document
    @commercial_document = current_organization.commercial_documents.find(params[:id])
  end

  def document_params
    params[document_name]&.permit(
      :contact_id,
      :account_id,
      :number,
      :date,
      :due_date,
      :status,
      :taxes_calculation,
      :taxes_attributes => [
        :id,
        :sales_tax_id,
        :calculate_from_rate,
        :amount,
        :_destroy
      ],
      :lines_attributes => [
        :id,
        :description,
        :account_id,
        :item_id,
        :quantity,
        :unit_price,
        :_destroy,
        :taxes_attributes => %i[
          id
          sales_tax_id
          _destroy
        ]
      ],
      attached_files: []
    )
  end

  def outgoing_email_params
    params[:outgoing_email]&.permit(
      :subject,
      :body
    )
  end

  def outgoing_email_recipients_params
    return unless params[:outgoing_email]

    params[:outgoing_email][:recipients].split(',')
  end
end
