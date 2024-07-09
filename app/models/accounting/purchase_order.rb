# frozen_string_literal: true

# == Schema Information
#
# Table name: commercial_documents
#
#  id                :uuid             not null, primary key
#  amount_due        :decimal(, )
#  amount_paid       :decimal(, )
#  currency          :string
#  date              :date
#  due_date          :date
#  exchange_rate     :decimal(, )
#  number            :string
#  status            :string
#  subtotal          :decimal(, )
#  taxes_amount      :decimal(, )
#  taxes_calculation :string
#  total             :decimal(, )
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :uuid
#  contact_id        :uuid
#  organization_id   :uuid
#
class PurchaseOrder < CommercialDocument
  extend Enumerize

  # Concerns
  include Draftable
  include Auditable

  # Enumerations
  enumerize :status, in: %i[draft new pending accepted completed], default: :draft

  #
  # Actions
  #

  def actions
    {
      paid: {
        primary: [
        ],
        secondary: [
        ]
      }
    }[status.to_sym] || { primary: [], secondary: [] }
  end
end
