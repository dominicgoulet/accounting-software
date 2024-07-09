# frozen_string_literal: true

class QuickbooksIntegration < CoreIntegration
  def generate_journal_entry(date, journalable_id, journalable_type, lines); end

  def remove_journal_entry(journalable_id, journalable_type); end

  # Trial_balance || Balance de vérification.xlsx : To make sure data is correctly loaded up
  # General_ledger || Grand livre.xlsx : To make sure data is correctly loaded up

  def import
    #MAX_SIZE = 1024**2 # 1MiB (but of course you can increase this)

    file = @integration.attached_files.first

    journal_sheet = nil
    balance_sheet = nil
    profit_and_loss_sheet = nil
    customers_sheet = nil
    employees_sheet = nil
    suppliers_sheet = nil
    trial_balance_sheet = nil
    general_ledger_sheet = nil

    file.open do |f|
      Zip::File.open(f) do |zip_file|
        zip_file.each do |entry|
          tf = entry.name
          basename = File.basename(tf)

          tf = Tempfile.new(basename)
          tf.binmode
          tf.write entry.get_input_stream.read
          tf.close

          xlsx = Roo::Spreadsheet.open(tf.path, extension: :xlsx)
          sheet = xlsx.sheet(0)

          organization_name = sheet.cell(1, 1)
          report_name = sheet.cell(2, 1)
          report_dates_range = sheet.cell(3, 1)

          case report_name.downcase
          when 'journal'
            journal_sheet = sheet
          when 'balance sheet', 'bilan'
            balance_sheet = sheet
          when 'profit and loss', 'état des résultats'
            profit_and_loss_sheet = sheet
          when 'customer contact list', 'liste des coordonnées des clients'
            customers_sheet = sheet
          when 'employee contact list', 'liste des coordonnées des employés'
            employees_sheet = sheet
          when 'supplier contact list', 'liste des coordonnées des fournisseurs'
            suppliers_sheet = sheet
          when 'trial balance', 'balance de vérification'
            trial_balance_sheet = sheet
          when 'general ledger', 'grand livre general'
            general_ledger_sheet = sheet
          end
        end
      end
    end

    # Import acccounts
    import_balance_sheet(balance_sheet)
    import_profit_and_loss(profit_and_loss_sheet)

    # Then contacts
    import_customers(customers_sheet)
    import_employees(employees_sheet)
    import_suppliers(suppliers_sheet)

    # Then transactions
    import_journal(journal_sheet)

    # Check and balance everything
    import_trial_balance(trial_balance_sheet)
    import_general_ledger(general_ledger_sheet)
  end

  def import_journal(sheet)
    contacts = {}
    accounts = {}

    journal_entry = nil

    @integration.journal_entries.destroy_all

    (sheet.last_row - 6 - 3).times do |index|
      row = index + 6

      date = sheet.cell(row, 2)
      type = sheet.cell(row, 3)
      number = sheet.cell(row, 4)
      contact_name = sheet.cell(row, 5)
      description = sheet.cell(row, 6)
      account_name = sheet.cell(row, 7)
      debit = sheet.cell(row, 8)
      credit = sheet.cell(row, 9)

      if contact_name.present?
        contacts[contact_name] = @organization.contacts.find_by(display_name: contact_name).id unless contacts[contact_name].present?
      end

      account_id = nil
      account_name = sheet.cell(row, 7)
      account_reference = nil

      if account_name.present?
        if account_name.split(' ').size > 0
          parts = account_name.split(' ')

          if parts[0] == parts[0].to_i.to_s
            reference = parts[0]
            account_name = parts[1..-1].join(' ')

            if account_name.split(':').size > 0
              account_name = account_name.split(':')[-1]
            end
          end
        end

        account_id = @organization.accounts.find_by(reference: reference, name: account_name).id

        accounts[[reference, account_name].join(' ')] = account_id unless accounts[account_id].present?
      end

      # We just reached a subtotal line, time to create the journal entry
      if account_name.nil? && debit.present? && credit.present? && debit == credit
        je = @organization.journal_entries.create(
          date: journal_entry[:date],
          narration: journal_entry[:type],
          integration_journalable_type: journal_entry[:type],
          integration_journalable_id: journal_entry[:number],
          integration: @integration)

        journal_entry[:lines].each do |line|
          je.journal_entry_lines.create(account_id: line[:account_id], description: line[:description], debit: line[:debit], credit: line[:credit])
        end

        # Reset it
        journal_entry = nil
      end

      # If we are on a new entry
      if journal_entry.nil? && date.present?
        journal_entry = {
          date: date,
          type: type,
          number: number,
          contact_id: contacts[contact_name],
          lines: []
        }
      end

      if journal_entry.present?
        journal_entry[:lines] << {
          account_id: accounts[[reference, account_name].join(' ')],
          description: description,
          debit: debit,
          credit: credit
        }
      end
    end

    true
  end

  def import_balance_sheet(sheet)
    import_accounts(sheet)
  end

  def import_profit_and_loss(sheet)
    import_accounts(sheet)
  end

  def import_accounts(sheet)
    # first 5 lines are not content
    # last 3 lines are not either
    total_number_of_rows = sheet.last_row
    total_number_of_rows -= 5 # Report header
    total_number_of_rows -= 3 # Report footer

    classification = nil
    account_sections = {}
    base_depth = 0
    current_depth = 0

    parent_account_stack = []

    total_number_of_rows.times do |index|
      row = index + 1 + 5 # Excel starts at index 1, +5 to account for the header

      reference = nil
      full_account_name = sheet.cell(row, 1) || ''
      account_name = full_account_name.lstrip

      if account_name.split(' ').size > 1
        parts = account_name.split(' ')

        if parts[0] == parts[0].to_i.to_s
          reference = parts[0]
          account_name = parts[1..-1].join(' ')
        end
      end

      account_balance = sheet.cell(row, 2)
      level = (full_account_name[/\A */].size / 3).to_i

      if ['Assets', 'ACTIFS'].include?(account_name) && level == 0
        classification = 'asset'
        base_depth = 0
        current_depth = 0
        parent_account_stack = []
      elsif ['Liabilities', 'Obligations'].include?(account_name) && level == 1
        classification = 'liability'
        base_depth = 1
        current_depth = 1
        parent_account_stack = []
      elsif ['Equity', 'Capital'].include?(account_name) && level == 1
        classification = 'equity'
        base_depth = 1
        current_depth = 1
        parent_account_stack = []
      elsif ['INCOME', 'REVENUS'].include?(account_name) && level == 1
        classification = 'income'
        base_depth = 1
        current_depth = 1
        parent_account_stack = []
      elsif ['EXPENSES', 'DÉPENSES'].include?(account_name) && level == 0
        classification = 'expense'
        base_depth = 0
        current_depth = 0
        parent_account_stack = []
      end

      if level > base_depth
        if level <= current_depth # on the same level, pop the parent
          parent_account_stack.pop
        end

        if level >= current_depth
          account = @organization.accounts.find_by(classification: classification, reference: reference, name: account_name)

          if account.present?
            account.update(
              classification: classification,
              reference: reference,
              name: account_name,
              parent_account: parent_account_stack.last)
          else
            account = @organization.accounts.create(
              reference: reference,
              name: account_name,
              classification: classification,
              parent_account: parent_account_stack.last)
          end

          parent_account_stack.push(account)
        end

        current_depth = level
      end
    end
  end

  def import_customers(sheet)
    # first 5 lines are not content
    # last 3 lines are not either
    total_number_of_rows = sheet.last_row
    total_number_of_rows -= 5 # Report header
    total_number_of_rows -= 3 # Report footer

    total_number_of_rows.times do |index|
      row = index + 1 + 5 # Excel starts at index 1, +5 to account for the header

      display_name = sheet.cell(row, 2)
      phone_number = sheet.cell(row, 3)
      email = sheet.cell(row, 4)
      full_name = sheet.cell(row, 5)
      first_name = full_name
      last_name = nil
      company_name = nil

      if full_name.present? && full_name.split(' ').size > 0
        first_name = full_name.split(' ')[0]
        last_name = full_name.split(' ')[1..-1].join(' ')
        company_name = display_name
      end

      billing_address = sheet.cell(row, 6)
      shipping_address = sheet.cell(row, 7)

      contact = @organization.contacts.find_or_create_by(display_name: display_name).update(
        phone_number: phone_number,
        email: email,
        is_customer: true,
        first_name: first_name,
        last_name: last_name,
        company_name: company_name)
    end
  end

  def import_employees(sheet)
    # first 5 lines are not content
    # last 3 lines are not either
    total_number_of_rows = sheet.last_row
    total_number_of_rows -= 5 # Report header
    total_number_of_rows -= 3 # Report footer

    total_number_of_rows.times do |index|
      row = index + 1 + 5 # Excel starts at index 1, +5 to account for the header

      display_name = sheet.cell(row, 2)
      phone_number = sheet.cell(row, 3)
      email = sheet.cell(row, 4)
      address = sheet.cell(row, 5)

      first_name = display_name
      last_name = nil
      company_name = @organization.name

      if display_name.present? && display_name.split(' ').size > 0
        first_name = display_name.split(' ')[0]
        last_name = display_name.split(' ')[1..-1].join(' ')
      end

      contact = @organization.contacts.find_or_create_by(display_name: display_name).update(
        phone_number: phone_number,
        email: email,
        is_employee: true,
        first_name: first_name,
        last_name: last_name,
        company_name: company_name)
    end
  end

  def import_suppliers(sheet)
    # first 5 lines are not content
    # last 3 lines are not either
    total_number_of_rows = sheet.last_row
    total_number_of_rows -= 5 # Report header
    total_number_of_rows -= 3 # Report footer

    total_number_of_rows.times do |index|
      row = index + 1 + 5 # Excel starts at index 1, +5 to account for the header

      display_name = sheet.cell(row, 2)
      phone_number = sheet.cell(row, 3)
      email = sheet.cell(row, 4)
      full_name = sheet.cell(row, 5)
      first_name = full_name
      last_name = nil
      company_name = nil

      if full_name.present? && full_name.split(' ').size > 0
        first_name = full_name.split(' ')[0]
        last_name = full_name.split(' ')[1..-1].join(' ')
        company_name = display_name
      end

      address = sheet.cell(row, 6)
      account_number = sheet.cell(row, 7)

      contact = @organization.contacts.find_or_create_by(display_name: display_name).update(
        phone_number: phone_number,
        email: email,
        is_vendor: true,
        first_name: first_name,
        last_name: last_name,
        company_name: company_name)
    end
  end

  def import_trial_balance(sheet)

  end

  def import_general_ledger(sheet)

  end
end
