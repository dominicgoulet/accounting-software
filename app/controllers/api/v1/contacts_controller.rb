# frozen_string_literal: true

module Api
  module V1
    class ContactsController < Api::V1::ApiController
      def index
        render json: current_organization.contacts
      end

      def show
        contact = current_organization.contacts.find(params[:id])

        render json: contact, status: :ok
      end

      def create
        contact = current_organization.contacts.build(contact_params)

        if contact.save
          current_integration.log_event(contact, 'create')

          render json: contact, status: :created
        else
          render json: contact.errors, status: :unprocessable_entity
        end
      end

      def update
        contact = current_organization.contacts.find(params[:id])

        if contact.update(contact_params)
          current_integration.log_event(contact, 'update')

          head :no_content
        else
          render json: contact.errors, status: :unprocessable_entity
        end
      end

      def destroy
        contact = current_organization.contacts.find(params[:id])

        if contact.destroy
          current_integration.log_event(contact, 'update')

          head :no_content
        else
          render json: contact.errors, status: :unprocessable_entity
        end
      end

      private

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
  end
end
