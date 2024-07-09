# frozen_string_literal: true

module BankTransactionable
  extend ActiveSupport::Concern

  included do
    # Associations
    has_many :bank_transaction_transactionables, as: :transactionable, dependent: :destroy
    has_many :bank_transactions, through: :bank_transaction_transactionables

    # Callbacks
    after_save :update_bank_transaction_transactionables

    # Hotwired
    after_create_commit :prepend_transactionable
    after_update_commit :update_transactionable
    after_destroy_commit :remove_transactionable
  end

  private

  def prepend_transactionable
    broadcast_prepend_to [organization, "#{self.class.name.underscore}_transactionable"],
                         inserts_by: :prepend,
                         partial: "bank_transaction_transactionables/details/#{self.class.name.underscore}"
  end

  def update_transactionable
    broadcast_replace_to [organization, "#{self.class.name.underscore}_transactionable"],
                         partial: "bank_transaction_transactionables/details/#{self.class.name.underscore}"
  end

  def remove_transactionable
    broadcast_remove_to [organization, "#{self.class.name.underscore}_transactionable"]
  end

  def update_bank_transaction_transactionables
    bank_transaction_transactionables.each(&:update_total)
  end
end
