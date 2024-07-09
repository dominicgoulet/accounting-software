# frozen_string_literal: true

class ComboboxComponent < ViewComponent::Base
  def initialize(form:, field:, kind:, options:, initial_value:, display_label: true)
    super
    @form = form
    @field = field
    @kind = kind
    @options = options
    @initial_value = initial_value
    @display_label = display_label
  end

  def new_form_url
    case @kind
    when 'account' then new_contextual_account_path
    when 'contact' then new_contextual_contact_path
    when 'item' then new_contextual_item_path
    when 'business_unit' then new_contextual_business_unit_path
    else raise
    end
  end
end
