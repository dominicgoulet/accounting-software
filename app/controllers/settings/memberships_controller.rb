# frozen_string_literal: true

module Settings
  class MembershipsController < Settings::SettingsController
    before_action :set_membership, only: %i[promote demote destroy]

    # POST /organizations/:id/memberships
    def create
      if params[:membership][:email] !~ /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
        respond_to do |format|
          format.turbo_stream do
            flash.now.alert = 'The provided email is not valid.'
            render partial: 'partials/flash', status: :unprocessable_entity
          end
        end
      else
        u = User.find_or_create_with_random_password(params[:membership][:email])

        if current_organization.member?(u)
          respond_to do |format|
            format.turbo_stream do
              flash.now.alert = 'This user is already member of the organization.'
              render partial: 'partials/flash'
            end
          end
        else
          @membership = current_organization.add_member!(u)
          ninetyfour_integration.log_event(@membership, 'create', current_user)

          respond_to do |format|
            format.turbo_stream do
              flash.now.notice = 'An email was sent to the user.'
              render partial: 'partials/flash'
            end
          end
        end
      end
    end

    # PATCH /memberships/1/promote
    def promote
      if current_organization.promote!(@membership.user)
        ninetyfour_integration.log_event(@membership, 'update', current_user)

        render json: { success: true }
      else
        render json: { error: 'This user could not be promoted to administrator of the organization.' },
               status: :unprocessable_entity
      end
    end

    # PATCH /memberships/1/demote
    def demote
      if current_organization.demote!(@membership.user)
        ninetyfour_integration.log_event(@membership, 'update', current_user)

        render json: { success: true }
      else
        render json: { error: 'This user could not be demoted to member of the organization.' },
               status: :unprocessable_entity
      end
    end

    def destroy
      if current_organization.remove_member!(@membership.user)
        ninetyfour_integration.log_event(@membership, 'destroy', current_user)

        respond_to do |format|
          format.turbo_stream do
            flash.now.notice = 'Member removed successfully.'
            render partial: 'partials/flash'
          end
        end
      else
        respond_to do |format|
          format.turbo_stream do
            flash.now.alert = 'This user could not be removed from the organization.'
            render partial: 'partials/flash', status: :unprocessable_entity
          end
        end
      end
    end

    def destroy_many
      @items = current_organization.memberships.where(id: params[:item_ids])

      @items.each do |item|
        if current_organization.remove_member!(item.user)
          ninetyfour_integration.log_event(item, 'destroy', current_user)
        end
      end

      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = "#{@items.count(&:destroyed?)} members out of #{@items.size} were successfully deleted."
          render partial: 'partials/flash'
        end
      end
    end

    private

    def set_membership
      @membership = current_organization.memberships.find(params[:id])
    end
  end
end
