# frozen_string_literal: true

class CoreIntegration
  def initialize(integration)
    @organization = integration.organization
    @integration = integration
  end

  def accounts_payable_account
    @organization.accounts.find_by(internal_code: 'ACCOUNTS_PAYABLE')
  end

  def accounts_receivable_account
    @organization.accounts.find_by(internal_code: 'ACCOUNTS_RECEIVABLE')
  end
end
