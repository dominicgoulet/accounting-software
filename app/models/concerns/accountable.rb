# frozen_string_literal: true

module Accountable
  extend ActiveSupport::Concern

  included do
    # Associations
    has_one :account, as: :accountable, dependent: :destroy

    # Callbacks
    after_create :create_account
    after_update :update_account

    # Nested attributes
    accepts_nested_attributes_for :account
  end

  private

  def create_account
    organization.accounts.create(
      accountable: self,
      generated: true,
      system: false,
      classification: classification_name,
      reference: next_reference,
      name: account_name || self.class.name
    )
  end

  def update_account
    organization.accounts.find_by(accountable: self).update(
      name: account_name
    )
  end

  def account_name
    case self.class.name
    when 'BankAccount'
      name
    when 'SalesTax'
      name
    end
  end

  def next_reference
    case self.class.name
    when 'BankAccount'
      b = organization.accounts.where(classification: classification_name,
                                      accountable_type: 'BankAccount').maximum('reference')
      (if b.present?
         b + 10
       else
         (classification_name == 'asset' ? 1000 : 2000)
       end)
    when 'SalesTax'
      b = organization.accounts.where(classification: 'liability', accountable_type: 'SalesTax').maximum('reference')
      (b.present? ? b + 10 : 2500)
    end
  end

  def classification_name
    case self.class.name
    when 'BankAccount'
      account_type == 'depository' || account_type == 'investment' ? 'asset' : 'liability'
    when 'SalesTax'
      'liability'
    end
  end
end
