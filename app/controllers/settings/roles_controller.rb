# frozen_string_literal: true

module Settings
  class RolesController < Settings::SettingsController
    before_action :ensure_frame_response, only: %i[new edit show]
    before_action :set_role, only: %i[show edit update destroy]

    def index
      @q = current_organization.roles.ransack(params[:q])
      @roles = @q.result
    end

    def show; end

    def new
      @role = Role.new
    end

    def new_contextual
      @role = Role.new
    end

    def create
      @role = current_organization.roles.build(role_params)

      if @role.save
        ninetyfour_integration.log_event(@role, 'create', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Role created successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @role.update(role_params)
        ninetyfour_integration.log_event(@role, 'update', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Role updated successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @role.destroy
        ninetyfour_integration.log_event(@role, 'destroy', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Role deleted successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            flash.now.alert = 'Role could not be deleted.'
            render partial: 'partials/flash'
          end
        end
      end
    end

    def destroy_many
      @items = current_organization.roles.where(id: params[:item_ids])
      destroyed_count = 0

      @items.each do |item|
        if item.destroy
          ninetyfour_integration.log_event(item, 'destroy', current_user)
          destroyed_count += 1
        end
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = "#{destroyed_count} roles out of #{@items.size} were successfully deleted."
          render partial: 'partials/flash'
        end
      end
    end

    private

    def set_role
      @role = current_organization.roles.find(params[:id])
    end

    def role_params
      params[:role].permit(
        :name,
        :description,
        membership_ids: []
      )
    end
  end
end
