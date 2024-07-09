# frozen_string_literal: true

class ReportQueryParameters::BusinessUnitsComponent < ViewComponent::Base
  def initialize(organization_id, business_unit_id)
    super
    @organization_id = organization_id
    @business_unit_id = business_unit_id
  end

  def options
    Organization.find(@organization_id).business_units.order(:name)
  end
end
