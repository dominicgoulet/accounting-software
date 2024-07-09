# frozen_string_literal: true

class SalesTaxPickerComponent < ViewComponent::Base
  def initialize(kind:, form:, field:, organization:)
    super
    @kind = kind
    @form = form
    @field = field
    @options = organization.present? ? organization.sales_taxes.map { |tax| [tax.id, tax.name, tax.rate] } : []
  end
end
