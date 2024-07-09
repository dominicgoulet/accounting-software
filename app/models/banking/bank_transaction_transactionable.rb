# frozen_string_literal: true

# == Schema Information
#
# Table name: bank_transaction_transactionables
#
#  id                   :uuid             not null, primary key
#  amount               :decimal(, )
#  transactionable_type :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  bank_transaction_id  :uuid
#  transactionable_id   :uuid
#
class BankTransactionTransactionable < ApplicationRecord
  # Associations
  belongs_to :bank_transaction
  belongs_to :transactionable, polymorphic: true

  # Validations
  validates :bank_transaction, presence: true
  validates :transactionable, presence: true
  validates_associated :transactionable

  # Callbacks
  after_save :update_bank_transaction
  after_destroy :update_bank_transaction # To trigger Hotwired content.
  before_save :set_amount
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  #
  # Totals
  #

  def update_total
    update(amount: total_amount_for_transactionable)
  end

  private

  def total_amount_for_transactionable
    case transactionable.class.name
    when 'Deposit'
      transactionable.total
    when 'Transfer'
      transactionable.amount
    when 'Expense'
      transactionable.total
    when 'BillPayment'
      transactionable.amount
    when 'InvoicePayment'
      transactionable.amount
    else
      0
    end
  end

  def update_bank_transaction
    bank_transaction.save
  end

  def set_amount
    self.amount = total_amount_for_transactionable
  end

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
