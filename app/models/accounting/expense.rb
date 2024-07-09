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
class Expense < CommercialDocument
  extend Enumerize

  # Concerns
  include Journalable
  include Auditable
  include BankTransactionable

  # Enumerations
  enumerize :status, in: %i[draft incomplete paid], default: :paid

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
