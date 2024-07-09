# frozen_string_literal: true

class AuditEventsController < ApplicationController
  def index
    @audit_events = current_organization.audit_events.where(
      auditable_type: params[:auditable_type],
      auditable_id: params[:auditable_id]
    ).order('occured_at DESC')
  end
end
