# frozen_string_literal: true

class ContactsController < ApplicationController
  layout 'people'
  before_action :ensure_frame_response, only: %i[new edit]
  before_action :set_contact,
                only: %i[show estimates invoices deposits purchase_orders bills expenses edit update destroy]

  def index
    @q = current_organization.contacts.ransack(params[:q])
    @contacts = @q.result
  end

  def show
    @q = current_organization.contacts.ransack(params[:q])
    @contacts = @q.result
  end

  def new
    @contact = Contact.new
  end

  def new_contextual
    @contact = Contact.new
  end

  def create
    @contact = current_organization.contacts.build(contact_params)

    if @contact.save
      ninetyfour_integration.log_event(@contact, 'create', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Contact created successfully.'
          render partial: 'partials/flash'
        end
        format.json { render json: { id: @contact.id, display_name: @contact.display_name }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    if @contact.update(contact_params)
      ninetyfour_integration.log_event(@contact, 'update', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Contact updated successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @contact.destroy
      ninetyfour_integration.log_event(@contact, 'destroy', current_user)

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = 'Contact deleted successfully.'
          render partial: 'partials/flash'
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = 'Contact could not be deleted.'
          render partial: 'partials/flash'
        end
      end
    end
  end

  def destroy_many
    @items = current_organization.contacts.where(id: params[:item_ids])
    destroyed_count = 0

    @items.each do |item|
      if item.destroy
        ninetyfour_integration.log_event(item, 'destroy', current_user)
        destroyed_count += 1
      end
    end

    respond_to do |format|
      format.turbo_stream do
        flash.now.notice = "#{destroyed_count} contacts out of #{@items.size} were successfully deleted."
        render partial: 'partials/flash'
      end
    end
  end

  private

  def set_contact
    @contact = current_organization.contacts.find(params[:id])
  end

  def contact_params
    params[:contact]&.permit(
      :first_name,
      :last_name,
      :company_name,
      :display_name,
      :phone_number,
      :email,
      :website
    )
  end
end
