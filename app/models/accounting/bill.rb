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
class Bill < CommercialDocument
  include Rails.application.routes.url_helpers
  extend Enumerize

  # Concerns
  include Journalable
  include Draftable
  include Auditable

  # Enumerations
  enumerize :status, in: %i[draft new late paid], default: :draft

  #
  # Actions
  #

  def actions
    {
      draft: {
        primary: [
          { route: accept_draft_bill_path(self), icon: 'mini/clipboard-document-check', label: 'Approve',
            turbo_method: :patch, primary: true }
        ],
        secondary: [
          { route: edit_bill_path(self), icon: 'mini/pencil-square', label: 'Edit', turbo_frame: :modal }
        ]
      },
      new: {
        primary: [
          { route: new_bill_payment_path(self), icon: 'mini/currency-dollar', label: 'Add payment',
            turbo_frame: :modal, primary: true }
        ],
        secondary: [
          { route: edit_bill_path(self), icon: 'mini/pencil-square', label: 'Edit', turbo_frame: :modal }
        ]
      },
      late: {
        primary: [
          { route: new_bill_payment_path(self), icon: 'mini/currency-dollar', label: 'Add payment',
            turbo_frame: :modal, primary: true }
        ],
        secondary: [
          { route: edit_bill_path(self), icon: 'mini/pencil-square', label: 'Edit', turbo_frame: :modal }
        ]
      }
    }[status.to_sym] || []
  end
end
