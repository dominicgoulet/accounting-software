# frozen_string_literal: true

class Report
  attr_accessor :organization_id, :start_date, :end_date, :date, :business_unit_id, :integration_id

  def initialize(organization_id)
    self.organization_id = organization_id
  end

  def current_year_earnings_account
    @current_year_earnings_account ||= Organization.find(self.organization_id).accounts.find_by(internal_code: 'CURRENT_YEAR_EARNINGS')
  end
end
