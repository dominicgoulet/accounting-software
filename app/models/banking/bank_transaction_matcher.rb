# frozen_string_literal: true

class BankTransactionMatcher
  # Find matches across all rules for an organization
  def self.execute(organization)
    # Find all matches based on user defined rules.
    organization.bank_transaction_rules.each do |rule|
      enforce_rule(rule)
    end

    # Check all imported transactions to find a potential match
    organization.bank_transactions.imported.each do |trx|
      matches = find_system_matches_for_transaction(trx)

      matches.each do |document|
        trx.match_document!(document)
      end
    end

    true
  end

  def self.verify(organization)
    matches = []
    # Find all matches based on user defined rules.
    organization.bank_transaction_rules.each do |rule|
      matches << find_matches_for_rule(rule)
    end

    # Check all imported transactions to find a potential match
    organization.bank_transactions.imported.each do |trx|
      matches << find_system_matches_for_transaction(trx)
    end

    matches
  end

  def self.enforce_rule(rule)
    matches = find_matches_for_rule(rule)

    matches.each do |trx|
      trx.match_rule!(rule)
    end
  end

  def self.verify_rule(rule)
    find_matches_for_rule(rule)
  end

  def self.apply(match)
    if match.user_defined?
      apply_user_defined_rule(match)
    else
      case match.matched_document_type
      when 'Invoice' then apply_invoice_match(match)
      when 'Bill' then apply_bill_match(match)
      end
    end

    true
  end

  def self.cancel(match)
    trx = match.bank_transaction
    match.destroy
    trx.update(status: :imported)
  end

  def self.find_matches_for_rule(rule)
    matches = []

    # understand what the rule is about
    clause = rule.match_all_conditions ? ' and ' : ' or '

    amount_multiplier = case rule.match_debit_or_credit
                        when 'credit' then 1
                        when 'debit' then -1
                        end
    conditions = []

    # construct rule from field -> condition -> value
    rule.bank_transaction_rule_conditions.each do |condition|
      field = {
        'amount': "(bank_transactions.amount * #{amount_multiplier})",
        'description': 'bank_transactions.name'
      }[condition.field]

      operator = {
        'is': '=',
        'lower_than': '<',
        'greater_than': '>',
        'contains': '~~*'
      }[condition.condition]

      value = {
        'is': condition.value,
        'lower_than': condition.value,
        'greater_than': condition.value,
        'contains': "'%#{condition.value}%'"
      }[condition.condition]

      conditions << "#{field} #{operator} #{value}"
    end

    query = conditions.join(clause)

    rule.organization.bank_transactions.imported.where(Arel.sql(query)).each do |trx|
      matches << trx if rule.bank_accounts.map(&:id).include? trx.bank_account_id
    end

    matches
  end

  def self.find_system_matches_for_transaction(trx)
    matches = []

    # there are 3 types of matches we are tryoing to find :
    # => Money IN and an invoice corresponding to the amount
    # => Money OUT and a bill corresponding to the amount
    # => Equivalent Money OUT to an IN or IN to an OUT in another account (a transfer)

    organization = trx.bank_account.organization

    if trx.debit?
      organization.invoices.outstanding.where('amount_due = ?', trx.debit).each do |invoice|
        matches << invoice
      end
    end

    if trx.credit?
      organization.bills.outstanding.where('amount_due = ?', trx.credit).each do |bill|
        matches << bill
      end
    end

    # transfers = organization.bank_accounts
    #   .joins(:bank_transactions)
    #   .where('(debit = ? AND debit > 0) or (credit = ? AND credit > 0)', trx.credit, trx.debit)

    matches
  end

  def self.apply_invoice_match(match)
    trx = match.bank_transaction
    org = trx.bank_account.organization

    trx.bank_transaction_transactionables.build(
      transactionable: org.invoice_payments.build(
        invoice: match.matched_document,
        account: trx.account,
        amount: trx.amount.abs,
        date: trx.date
      )
    ).save

    trx.update(status: :described)
  end

  def self.apply_bill_match(match)
    trx = match.bank_transaction
    org = trx.bank_account.organization

    trx.bank_transaction_transactionables.build(
      transactionable: org.bill_payments.build(
        bill: match.matched_document,
        account: trx.account,
        amount: trx.amount.abs,
        date: trx.date
      )
    ).save

    trx.update(status: :described)
  end

  def self.apply_user_defined_rule(match)
    rule = match.rule
    trx = match.bank_transaction
    org = trx.bank_account.organization

    case rule.action
    when 'describe'
      case rule.document_type
      when 'Expense', 'Deposit'
        document = rule.document_type.constantize.new(
          organization: org,
          contact: rule.contact,
          account: trx.account,
          date: trx.date,
          taxes_calculation: 'inclusive'
        )

        rule.bank_transaction_rule_document_lines.each do |line|
          doc_line = document.lines.build(
            account: line.account,
            quantity: 1,
            unit_price: line.percentage / 100.0 * trx.amount.abs
          )

          line.taxes.each do |tax|
            doc_line.taxes.build(sales_tax_id: tax.sales_tax_id)
          end
        end

        document.save

        trx.bank_transaction_transactionables.build(transactionable: document)
        trx.update(status: :described)
      when 'Transfer'
        transfer = rule.bank_transaction_rule_document_lines.first

        trx.bank_transaction_transactionables.build(transactionable:
          org.transfers.build(
            from_account: trx.account,
            to_account: transfer.account,
            amount: transfer.percentage / 100.0 * trx.amount.abs,
            date: trx.date
          )).save

        trx.update(status: :described)
      end
    when 'reject'
      trx.reject
    end
  end
end
