# frozen_string_literal: true

class ReportQueryParameters::DateComponent < ViewComponent::Base
  def initialize(organization_id, date)
    super
    @organization_id = organization_id
    @date = date
  end
end
