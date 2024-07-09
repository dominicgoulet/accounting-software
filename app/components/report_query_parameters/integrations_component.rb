# frozen_string_literal: true

class ReportQueryParameters::IntegrationsComponent < ViewComponent::Base
  def initialize(organization_id, integration_id)
    super
    @organization_id = organization_id
    @integration_id = integration_id
  end

  def options
    Organization.find(@organization_id).integrations.order('system desc, name asc')
  end
end
