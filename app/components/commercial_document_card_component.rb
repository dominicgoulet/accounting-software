# frozen_string_literal: true

class CommercialDocumentCardComponent < ViewComponent::Base
  with_collection_parameter :document

  def initialize(document:)
    super
    @document = document
  end

  def format_amount(amount)
    amount = 0 unless amount.present?
    "$ #{number_to_currency(amount, unit: '', separator: '.', delimiter: ' ')}"
  end

  def format_quantity(quantity)
    return quantity.to_i if quantity == quantity.to_i

    quantity
  end

  def sti_path(action = nil)

    return {
      controller: 'commercial_documents',
      action: action,
      type: @document.type,
      id: @document.id
    }

    args = [@document.type.underscore.downcase.pluralize.to_sym]

    if action.present?
      args = if [:new].include? action
               [action, @document.type.underscore.downcase.to_sym]
             elsif [:show].include? action
               {:action=>"show", :controller=>"commercial_documents", :type=>@document.type, :id=>@document.id}
             else
               [action, @document.type.underscore.downcase.pluralize.to_sym]
             end
    end



    polymorphic_path(args)
  end
end
