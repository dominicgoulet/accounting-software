# frozen_string_literal: true

module Settings
  class IntegrationsController < Settings::SettingsController
    before_action :ensure_frame_response, only: %i[new edit]
    before_action :set_integration, only: %i[show edit update destroy]

    def index
      @q = current_organization.integrations.ransack(params[:q])
      @integrations = @q.result
    end

    def show; end

    def new
      @integration = Integration.new
    end

    def new_contextual
      @integration = Integration.new
    end

    def create
      @integration = current_organization.integrations.build(integration_params)

      @integration.setup_specific_integration(params[:integration][:integration_type])

      if @integration.save
        ninetyfour_integration.log_event(@integration, 'create', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Integration created successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @integration.update(integration_params)
        ninetyfour_integration.log_event(@integration, 'update', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Integration updated successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @integration.destroy
        ninetyfour_integration.log_event(@integration, 'destroy', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Integration deleted successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            flash.now.alert = 'Integration could not be deleted.'
            render partial: 'partials/flash'
          end
        end
      end
    end

    def destroy_many
      @items = current_organization.integrations.where(id: params[:item_ids])
      destroyed_count = 0

      @items.each do |item|
        if item.destroy
          ninetyfour_integration.log_event(item, 'destroy', current_user)
          destroyed_count += 1
        end
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = "#{destroyed_count} integrations out of #{@items.size} were successfully deleted."
          render partial: 'partials/flash'
        end
      end
    end

    private

    def set_integration
      @integration = current_organization.integrations.find(params[:id])
    end

    def integration_params
      params[:integration].permit(
        :name,
        :webhook_url,
        subscribed_webhooks: [],
        attached_files: []
      )
    end
  end
end
