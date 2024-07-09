# frozen_string_literal: true

module Settings
  class BusinessUnitsController < Settings::SettingsController
    before_action :ensure_frame_response, only: %i[new edit]
    before_action :set_business_unit, only: %i[show edit update destroy]

    def index
      @q = current_organization.business_units.ransack(params[:q])
      @business_units = @q.result
    end

    def show; end

    def new
      @business_unit = BusinessUnit.new
    end

    def new_contextual
      @business_unit = BusinessUnit.new
    end

    def create
      @business_unit = current_organization.business_units.build(business_unit_params)

      if @business_unit.save
        ninetyfour_integration.log_event(@business_unit, 'create', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Business unit created successfully.'
            render partial: 'partials/flash'
          end
          format.json { render json: { id: @business_unit.id, display_name: @business_unit.name }, status: :created }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @business_unit.update(business_unit_params)
        ninetyfour_integration.log_event(@business_unit, 'update', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Business unit updated successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @business_unit.destroy
        ninetyfour_integration.log_event(@business_unit, 'destroy', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Business unit deleted successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            flash.now.alert = 'Business unit could not be deleted.'
            render partial: 'partials/flash'
          end
        end
      end
    end

    def destroy_many
      @items = current_organization.business_units.where(id: params[:item_ids])
      destroyed_count = 0

      @items.each do |item|
        if item.destroy
          ninetyfour_integration.log_event(item, 'destroy', current_user)
          destroyed_count += 1
        end
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = "#{destroyed_count} business units out of #{@items.size} were successfully deleted."
          render partial: 'partials/flash'
        end
      end
    end

    private

    def set_business_unit
      @business_unit = current_organization.business_units.find(params[:id])
    end

    def business_unit_params
      params[:business_unit].permit(
        :name,
        :description,
        :parent_business_unit_id
      )
    end
  end
end
