# frozen_string_literal: true

class NinetyfourIntegration < CoreIntegration
  def generate_journal_entry(date, journalable_id, journalable_type)
    journal_entry = @organization.journal_entries.find_by(
      journalable_id:,
      journalable_type:,
      integration_id: @integration.id
    )

    if journal_entry.present?
      journal_entry.update(date:)
    else
      journal_entry = @organization.journal_entries.create(
        journalable_id:,
        journalable_type:,
        date:,
        integration: @integration
      )
    end

    generate_journal_entry_lines(journal_entry)
  end

  def remove_journal_entry(journalable_id, journalable_type)
    @organization.journal_entries.find_by(
      journalable_id:,
      journalable_type:
    )&.destroy
  end

  def generate_journal_entry_lines(journal_entry)
    case journal_entry.journalable.class.name
    when 'Bill'
      # FIXME : Find a better way to diff the lines to delete
      journal_entry.journal_entry_lines.delete_all

      journal_entry.journal_entry_lines.find_or_create_by(account: accounts_payable_account, contact: journal_entry.journalable.contact).increment!(:credit,
                                                                                                        journal_entry.journalable.total)

      journal_entry.journalable.lines.each do |line|
        journal_entry.journal_entry_lines.find_or_create_by(account: line.account).increment!(:debit, line.subtotal)
      end

      journal_entry.journalable.taxes.each do |tax|
        journal_entry.journal_entry_lines.find_or_create_by(account: tax.sales_tax.account).increment!(:debit,
                                                                                                       tax.amount || 0)
      end

    when 'BillPayment'
      # FIXME : Find a better way to diff the lines to delete
      journal_entry.journal_entry_lines.delete_all

      journal_entry.journal_entry_lines.find_or_create_by(account: journal_entry.journalable.account).increment!(
        :credit, journal_entry.journalable.amount
      )
      journal_entry.journal_entry_lines.find_or_create_by(account: accounts_payable_account, contact: journal_entry.journalable.contact).increment!(:debit,
                                                                                                        journal_entry.journalable.amount)

    when 'Expense'
      # FIXME : Find a better way to diff the lines to delete
      journal_entry.journal_entry_lines.delete_all

      journal_entry.journal_entry_lines.find_or_create_by(account: journal_entry.journalable.account).increment!(
        :credit, journal_entry.journalable.total
      )

      journal_entry.journalable.lines.each do |line|
        journal_entry.journal_entry_lines.find_or_create_by(account: line.account).increment!(:debit, line.subtotal)
      end

      journal_entry.journalable.taxes.each do |tax|
        journal_entry.journal_entry_lines.find_or_create_by(account: tax.sales_tax.account).increment!(:debit,
                                                                                                       tax.amount || 0)
      end

    when 'VendorCredit'
      # FIXME : Find a better way to diff the lines to delete
      journal_entry.journal_entry_lines.delete_all

      journal_entry.journal_entry_lines.find_or_create_by(account: accounts_receivable_account, contact: journal_entry.journalable.contact).increment!(:debit,
                                                                                                           journal_entry.journalable.amount)

      journal_entry.journalable.vendor_credit_lines.each do |line|
        journal_entry.journal_entry_lines.find_or_create_by(account: line.account).increment!(:credit, line.subtotal)
      end

      journal_entry.journalable.vendor_credit_taxes.each do |tax|
        journal_entry.journal_entry_lines.find_or_create_by(account: tax.sales_tax.account).increment!(:credit,
                                                                                                       tax.amount || 0)
      end

    when 'Invoice'
      # FIXME : Find a better way to diff the lines to delete
      journal_entry.journal_entry_lines.delete_all

      journal_entry.journal_entry_lines.find_or_create_by(account: accounts_receivable_account, contact: journal_entry.journalable.contact).increment!(:debit,
                                                                                                           journal_entry.journalable.total)

      journal_entry.journalable.lines.each do |line|
        journal_entry.journal_entry_lines.find_or_create_by(account: line.item.income_account).increment!(:credit,
                                                                                                          line.subtotal)
      end

      journal_entry.journalable.taxes.each do |tax|
        journal_entry.journal_entry_lines.find_or_create_by(account: tax.sales_tax.account).increment!(:credit,
                                                                                                       tax.amount || 0)
      end

    when 'InvoicePayment'
      # FIXME : Find a better way to diff the lines to delete
      journal_entry.journal_entry_lines.delete_all

      journal_entry.journal_entry_lines.find_or_create_by(account: accounts_receivable_account, contact: journal_entry.journalable.contact).increment!(:credit,
                                                                                                           journal_entry.journalable.amount)
      journal_entry.journal_entry_lines.find_or_create_by(account: journal_entry.journalable.account).increment!(
        :debit, journal_entry.journalable.amount
      )

    when 'Deposit'
      # FIXME : Find a better way to diff the lines to delete
      journal_entry.journal_entry_lines.delete_all

      journal_entry.journal_entry_lines.find_or_create_by(account: journal_entry.journalable.account).increment!(
        :debit, journal_entry.journalable.total
      )

      journal_entry.journalable.lines.each do |line|
        journal_entry.journal_entry_lines.find_or_create_by(account: line.account).increment!(:credit, line.subtotal)
      end

      journal_entry.journalable.taxes.each do |tax|
        journal_entry.journal_entry_lines.find_or_create_by(account: tax.sales_tax.account).increment!(:credit,
                                                                                                       tax.amount || 0)
      end

    when 'CreditMemo'
      # FIXME : Find a better way to diff the lines to delete
      journal_entry.journal_entry_lines.delete_all

      journal_entry.journal_entry_lines.find_or_create_by(account: accounts_receivable_account, contact: journal_entry.journalable.contact).increment!(:credit,
                                                                                                           journal_entry.journalable.amount)

      journal_entry.journalable.credit_memo_lines.each do |line|
        journal_entry.journal_entry_lines.find_or_create_by(account: line.account).increment!(:debit, line.subtotal)
      end

      journal_entry.journalable.credit_memo_taxes.each do |tax|
        journal_entry.journal_entry_lines.find_or_create_by(account: tax.sales_tax.account).increment!(:debit,
                                                                                                       tax.amount || 0)
      end

    when 'Transfer'
      # FIXME : Find a better way to diff the lines to delete
      journal_entry.journal_entry_lines.delete_all

      journal_entry.journal_entry_lines.find_or_create_by(account: journal_entry.journalable.from_account).increment!(
        :credit, journal_entry.journalable.amount || 0
      )
      journal_entry.journal_entry_lines.find_or_create_by(account: journal_entry.journalable.to_account).increment!(
        :debit, journal_entry.journalable.amount || 0
      )
    end
  end
end
