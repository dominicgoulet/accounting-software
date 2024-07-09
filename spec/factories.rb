# frozen_string_literal: true

FactoryBot.define do
  factory :commercial_document_payment do
    organization
    document factory: :commercial_document
    account
    date { Date.today }
    amount { 1 }
  end

  factory :commercial_document_line_tax do
    line factory: :commercial_document_line
    sales_tax
  end

  factory :commercial_document_line do
    document factory: :commercial_document
    account
  end

  factory :commercial_document_tax do
    sales_tax
    document factory: :commercial_document
  end

  factory :commercial_document do
    organization
    contact
    type { 'Invoice' }
    date { Date.today }
  end

  factory :bill do
    organization
    contact
    date { Date.today }
  end

  factory :deposit do
    organization
    account
    contact
    date { Date.today }
  end

  factory :estimate do
    organization
    contact
    date { Date.today }
  end

  factory :expense do
    organization
    account
    contact
    date { Date.today }
  end

  factory :invoice do
    organization
    contact
    date { Date.today }
  end

  factory :purchase_order do
    organization
    contact
    date { Date.today }
  end

  sequence :email do |n|
    "test_#{n}@test.org"
  end

  factory :organization do
    name { 'My organization' }
  end

  factory :user do
    email { generate(:email) }
    password { '0000' }
  end

  factory :membership do
    user
    organization
  end

  factory :role do
    organization
    name { 'My role' }
  end

  factory :role_member do
    role
    membership
  end

  factory :business_unit do
    organization
    name { 'My business unit' }
  end

  factory :permission do
    organization
    role
    business_unit
  end

  factory :integration do
    organization
    name { 'My integration' }
  end

  factory :contact do
    organization
    display_name { 'My contact' }
  end

  factory :item do
    organization
    name { 'My item' }
  end

  factory :account do
    organization
    name { 'My account' }
  end

  factory :account_tax do
    account
    sales_tax
  end

  factory :sales_tax do
    organization
    name { 'My sales tax' }
    rate { 5 }
  end

  factory :journal_entry do
    integration
    organization
    date { Date.today }
  end

  factory :journal_entry_line do
    journal_entry
    account
  end

  factory :audit_event do
    integration
    organization
    auditable { FactoryBot.create(:item) }
    action { 'create' }
  end

  #
  # Banking
  #

  factory :bank_credential do
    organization
    access_token { 'access_token' }
  end

  factory :bank_account do
    bank_credential
  end

  factory :bank_transaction do
    bank_account
  end

  factory :bank_transaction_rule do
    organization
    name { 'My rule' }
  end

  factory :bank_transaction_rule_account do
    bank_transaction_rule
    bank_account
  end

  factory :bank_transaction_rule_condition do
    bank_transaction_rule
  end

  factory :bank_transaction_rule_document_line do
    bank_transaction_rule
    account
  end

  factory :bank_transaction_rule_document_line_tax do
    bank_transaction_rule_document_line
    sales_tax
  end

  factory :bank_transaction_rule_match do
    organization
    bank_transaction
    rule { FactoryBot.create(:bank_transaction_rule) }
    # matched_document { FactoryBot.create(:commercial_document) }
  end

  factory :bank_transaction_transactionable do
    bank_transaction
    transactionable { FactoryBot.create(:commercial_document) }
  end

  factory :transfer do
    organization
    date { Date.today }
    from_account factory: :account
    to_account factory: :account
  end

  factory :address do
    addressable factory: :contact
  end

  factory :outgoing_email do
    organization
    recipients { ['test@test.org'] }
    subject { 'My subject' }
  end

  factory :recurring_event do
    organization
    recurrable factory: :journal_entry
  end
end
