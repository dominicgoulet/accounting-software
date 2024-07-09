# frozen_string_literal: true

module Settings
  class PermissionsController < ApplicationController
    before_action :set_permission, only: %i[permission_level_none permission_level_view permission_level_edit]

    # PATCH /permissions/1/permission_level_none
    def permission_level_none
      if @permission.permission_level_none!
        ninetyfour_integration.log_event(@permission, 'update', current_user)

        render json: { success: true }
      else
        render json: { error: 'This user could not be promoted to administrator of the organization.' },
               status: :unprocessable_entity
      end
    end

    # PATCH /permissions/1/permission_level_view
    def permission_level_view
      if @permission.permission_level_view!
        ninetyfour_integration.log_event(@permission, 'update', current_user)

        render json: { success: true }
      else
        render json: { error: 'This user could not be promoted to administrator of the organization.' },
               status: :unprocessable_entity
      end
    end

    # PATCH /permissions/1/permission_level_edit
    def permission_level_edit
      if @permission.permission_level_edit!
        ninetyfour_integration.log_event(@permission, 'update', current_user)

        render json: { success: true }
      else
        render json: { error: 'This user could not be promoted to administrator of the organization.' },
               status: :unprocessable_entity
      end
    end

    private

    def set_permission
      @permission = current_organization.permissions.find(params[:id])
    end
  end
end
