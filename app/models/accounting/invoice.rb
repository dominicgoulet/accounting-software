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
class Invoice < CommercialDocument
  include Rails.application.routes.url_helpers
  extend Enumerize

  # Concerns
  include Journalable
  include Draftable
  include Auditable

  # Enumerations
  enumerize :status, in: %i[draft new sent late paid], default: :draft

  def mark_as_sent!
    update(status: :sent)
  end

  def mark_as_new!
    update(status: :new)
  end

  def most_recent_payment
    payments.order(:date).last
  end

  #
  # Actions
  #

  def actions
    {
      draft: {
        primary: [
          { route: accept_draft_invoice_path(self), icon: 'mini/clipboard-document-check', label: 'Approve',
            turbo_method: :patch, primary: true }
        ],
        secondary: [
          { route: edit_invoice_path(self), icon: 'mini/pencil-square', label: 'Edit', turbo_frame: :modal }
        ]
      },
      new: {
        primary: [
          { route: prepare_email_invoice_path(self), icon: 'mini/envelope', label: 'Send', turbo_frame: :modal,
            primary: true }
        ],
        secondary: [
          { route: return_to_draft_invoice_path(self), icon: 'mini/clipboard-document', label: 'Return to draft',
            turbo_method: :patch },
          { route: mark_as_sent_invoice_path(self), icon: 'mini/check', label: 'Mark as sent', turbo_method: :patch },
          { route: edit_invoice_path(self), icon: 'mini/pencil-square', label: 'Edit', turbo_frame: :modal }
        ]
      },
      sent: {
        primary: [
          { route: new_invoice_payment_path(self), icon: 'mini/currency-dollar', label: 'Add payment',
            turbo_frame: :modal, primary: true }
        ],
        secondary: [
          { route: mark_as_new_invoice_path(self), icon: 'mini/clipboard-document-check', label: 'Mark as new',
            turbo_method: :patch },
          { route: edit_invoice_path(self), icon: 'mini/pencil-square', label: 'Edit', turbo_frame: :modal },
          { route: prepare_email_invoice_path(self), icon: 'mini/envelope', label: 'Send reminder',
            turbo_frame: :modal }
        ]
      },
      late: {
        primary: [
          { route: new_invoice_payment_path(self), icon: 'mini/currency-dollar', label: 'Add payment',
            turbo_frame: :modal, primary: true }
        ],
        secondary: [
          { route: edit_invoice_path(self), icon: 'mini/pencil-square', label: 'Edit', turbo_frame: :modal },
          { route: prepare_email_invoice_path(self), icon: 'mini/envelope', label: 'Send reminder',
            turbo_frame: :modal }
        ]
      }
    }[status.to_sym] || { primary: [], secondary: [] }
  end
end
