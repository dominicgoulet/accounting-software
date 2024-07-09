# frozen_string_literal: true

module Settings
  class OrganizationsController < Settings::SettingsController
    before_action :set_organization, only: %i[show edit update members roles business_units permissions destroy]

    def index
      @organizations = current_user.organizations
    end

    def show; end

    def new
      @organization = Organization.new
    end

    def create
      @organization = current_user.organizations.build(organization_params)

      if @organization.save
        ninetyfour_integration.log_event(@organization, 'create', current_user)

        @organization.define_owner!(current_user)
        current_user.current_organization!(@organization)

        redirect_to setup_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def sign_in
      organization = current_user.organizations.find(params[:id])
      current_user.current_organization!(organization)

      redirect_to root_path
    end

    def update
      if @organization.update(organization_params)
        ninetyfour_integration.log_event(@organization, 'update', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Organization updated successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def members
      @q = current_organization.memberships.joins(:user).includes(:user).ransack(params[:q])
      @memberships = @q.result
    end

    def roles
      @q = current_organization.roles.ransack(params[:q])
      @roles = @q.result
    end

    def business_units
      @q = current_organization.business_units.ransack(params[:q])
      @business_units = @q.result
    end

    def permissions; end

    def destroy
      if @organization.destroy
        ninetyfour_integration.log_event(@organization, 'destroy', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Account deleted successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            flash.now.alert = 'Account could not be deleted.'
            render partial: 'partials/flash'
          end
        end
      end
    end

    private

    def set_organization
      @organization = current_user.organizations.find(params[:id])
    end

    def organization_params
      params[:organization].permit(
        :name,
        :website
      )
    end
  end
end
