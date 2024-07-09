# frozen_string_literal: true

class ReportQueryParameters::PeriodOfTimeComponent < ViewComponent::Base
  def initialize(organization_id, start_date, end_date)
    super
    @organization_id = organization_id
    @start_date = start_date
    @end_date = end_date
  end
end
