# frozen_string_literal: true

module Api
  module V1
    class JournalEntriesController < Api::V1::ApiController
      def index
        render json: current_organization.journal_entries
      end

      def show
        journal_entry = current_organization.journal_entries.find(params[:id])

        render json: journal_entry, status: :ok
      end

      def create
        journal_entry = current_organization.journal_entries.build(journal_entry_params)
        journal_entry.integration = current_integration

        if journal_entry.save
          current_integration.log_event(journal_entry, 'create')

          render json: journal_entry, status: :created
        else
          render json: journal_entry.errors, status: :unprocessable_entity
        end
      end

      def update
        journal_entry = current_organization.journal_entries.find(params[:id])

        if journal_entry.update(journal_entry_params)
          current_integration.log_event(journal_entry, 'update')

          head :no_content
        else
          render json: journal_entry.errors, status: :unprocessable_entity
        end
      end

      def destroy
        journal_entry = current_organization.journal_entries.find(params[:id])

        if journal_entry.destroy
          current_integration.log_event(journal_entry, 'update')

          head :no_content
        else
          render json: journal_entry.errors, status: :unprocessable_entity
        end
      end

      private

      def journal_entry_params
        params[:journal_entry]&.permit(
          :contact_id,
          :date,
          :narration,
          :integration_journalable_type,
          :integration_journalable_id,
          journal_entry_lines_attributes: %i[
            id
            account_id
            credit
            debit
            _destroy
          ],
          attached_files: []
        )
      end
    end
  end
end
