class ProfitAndLossReport < Report
  #
  # Fields
  #

  F_CLASSIFICATION = 0
  F_ID = 1
  F_REFERENCE = 2
  F_NAME = 3
  F_PARENT_ACCOUNT_ID = 4
  F_TOTAL = 5

  F_JANUARY = 6
  F_FEBRUARY = 7
  F_MARCH = 8
  F_APRIL = 9
  F_MAY = 10
  F_JUNE = 11
  F_JULY = 12
  F_AUGUST = 13
  F_SEPTEMBER = 14
  F_OCTOBER = 15
  F_NOVEMBER = 16
  F_DECEMBER = 17

  def query_parameters_components
    [
      ReportQueryParameters::PeriodOfTimeComponent.new(self.organization_id, self.start_date, self.end_date),
      # ReportQueryParameters::BusinessUnitsComponent.new(self.organization_id, self.business_unit_id),
      # ReportQueryParameters::IntegrationsComponent.new(self.organization_id, self.integration_id)
    ]
  end

  def execute
    sql = ActiveRecord::Base::sanitize_sql([%{
      SELECT *,
             CASE classification
             WHEN 'income' THEN 1
             WHEN 'expense' THEN 2
             WHEN 'earnings' THEN 3
             ELSE 999
             END AS rank
        FROM (

              SELECT accounts.classification,
                     accounts.id,
                     accounts.reference,
                     accounts.name,
                     accounts.parent_account_id,
                     CASE accounts.classification
                     WHEN 'income' THEN SUM(credit) - SUM(debit)
                     WHEN 'expense' THEN SUM(debit) - SUM(credit)
                     END AS total,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 1 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS january,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 2 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS february,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 3 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS march,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 4 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS april,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 5 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS may,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 6 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS june,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 7 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS july,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 8 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS august,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 9 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS september,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 10 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS october,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 11 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS november,

                     CASE EXTRACT(MONTH FROM journal_entries.date)
                     WHEN 12 THEN
                      CASE accounts.classification
                       WHEN 'income' THEN SUM(credit) - SUM(debit)
                       WHEN 'expense' THEN SUM(debit) - SUM(credit)
                       END
                     END AS december

                FROM accounts
           LEFT JOIN (journal_entry_lines INNER JOIN journal_entries
                                                  ON journal_entry_lines.journal_entry_id = journal_entries.id
                                                 AND journal_entries.date BETWEEN ? AND ?)
                      ON accounts.id = journal_entry_lines.account_id
               WHERE accounts.organization_id = ?
                 AND accounts.classification IN ('income', 'expense')
            GROUP BY accounts.classification,
                     accounts.id,
                     accounts.reference,
                     accounts.name,
                     EXTRACT(MONTH FROM journal_entries.date)

               UNION ALL

              SELECT 'earnings' AS classification,
                     ? AS id,
                     ? AS reference,
                     ? AS name,
                     ? AS parent_account_id,
                     SUM(credit) - SUM(debit) AS total,
                     0 as january,
                     0 as february,
                     0 as march,
                     0 as april,
                     0 as may,
                     0 as june,
                     0 as july,
                     0 as august,
                     0 as september,
                     0 as october,
                     0 as november,
                     0 as december
                FROM accounts
          INNER JOIN journal_entry_lines ON accounts.id = journal_entry_lines.account_id
          INNER JOIN journal_entries ON journal_entry_lines.journal_entry_id = journal_entries.id AND journal_entries.date BETWEEN ? AND ?
               WHERE accounts.organization_id = ?
                 AND accounts.classification IN ('income', 'expense')

              ) AS SubQuery
        ORDER BY rank,
                 reference,
                 name
      },
      start_date,
      end_date,
      self.organization_id,
      current_year_earnings_account.id,
      current_year_earnings_account.reference,
      current_year_earnings_account.name,
      current_year_earnings_account.parent_account_id,
      start_date,
      end_date,
      self.organization_id
    ])

    rows = ActiveRecord::Base.connection.exec_query(sql).rows
    dict = {}

    rows.each do |row|
      dict[row[F_ID]] = {
        classification: row[F_CLASSIFICATION],
        id: row[F_ID],
        reference: row[F_REFERENCE],
        name: row[F_NAME],
        parent_account_id: row[F_PARENT_ACCOUNT_ID],
        balance: row[F_TOTAL] || 0.0,
        total: row[F_TOTAL] || 0.0,
        january: row[F_JANUARY] || 0.0,
        february: row[F_FEBRUARY] || 0.0,
        march: row[F_MARCH] || 0.0,
        april: row[F_APRIL] || 0.0,
        may: row[F_MAY] || 0.0,
        june: row[F_JUNE] || 0.0,
        july: row[F_JULY] || 0.0,
        august: row[F_AUGUST] || 0.0,
        september: row[F_SEPTEMBER] || 0.0,
        october: row[F_OCTOBER] || 0.0,
        november: row[F_NOVEMBER] || 0.0,
        december: row[F_DECEMBER] || 0.0,
        children: []
      }
    end

    # Create the hierarchy
    dict.keys.each do |key|
      el = dict[key]

      if el[:parent_account_id].present? && dict[el[:parent_account_id]].present?
        parent = dict[el[:parent_account_id]]

        parent[:children] << el
      end
    end

    # Second pass to remove children from root
    dict.keys.each do |key|
      dict.delete(key) if dict[key][:parent_account_id].present?
    end

    report = {
      income: {
        lines: [],
        total: 0.0,
        months: [
          { name: 'January', total: 0.0 },
          { name: 'February', total: 0.0 },
          { name: 'March', total: 0.0 },
          { name: 'April', total: 0.0 },
          { name: 'May', total: 0.0 },
          { name: 'June', total: 0.0 },
          { name: 'July', total: 0.0 },
          { name: 'August', total: 0.0 },
          { name: 'September', total: 0.0 },
          { name: 'October', total: 0.0 },
          { name: 'November', total: 0.0 },
          { name: 'December', total: 0.0 },
        ],
      },
      expense: {
        lines: [],
        total: 0.0,
        months: [
          { name: 'January', total: 0.0 },
          { name: 'February', total: 0.0 },
          { name: 'March', total: 0.0 },
          { name: 'April', total: 0.0 },
          { name: 'May', total: 0.0 },
          { name: 'June', total: 0.0 },
          { name: 'July', total: 0.0 },
          { name: 'August', total: 0.0 },
          { name: 'September', total: 0.0 },
          { name: 'October', total: 0.0 },
          { name: 'November', total: 0.0 },
          { name: 'December', total: 0.0 },
        ],
      },
      earnings: {
        lines: [],
        total: 0.0,
        months: [
          { name: 'January', total: 0.0 },
          { name: 'February', total: 0.0 },
          { name: 'March', total: 0.0 },
          { name: 'April', total: 0.0 },
          { name: 'May', total: 0.0 },
          { name: 'June', total: 0.0 },
          { name: 'July', total: 0.0 },
          { name: 'August', total: 0.0 },
          { name: 'September', total: 0.0 },
          { name: 'October', total: 0.0 },
          { name: 'November', total: 0.0 },
          { name: 'December', total: 0.0 },
        ],
      }
    }

    dict.keys.each do |key|
      el = dict[key]

      report[el[:classification].to_sym][:lines] << process_line(el)
      report[el[:classification].to_sym][:total] += report[el[:classification].to_sym][:lines][-1][:total]

      12.times do |i|
        report[el[:classification].to_sym][:months][i][:total] += report[el[:classification].to_sym][:lines][-1][:months][i][:total]
      end
    end

    report
  end

  def process_line(el)
    line = {
      account: {
        id: el[:id],
        reference: el[:reference],
        name: el[:name],
        parent_account_id: el[:parent_account_id]
      },
      balance: el[:balance].to_f,
      total: el[:total].to_f,
      months: [
        { name: 'January', balance: el[:january], total: el[:january] },
        { name: 'February', balance: el[:february], total: el[:february] },
        { name: 'March', balance: el[:march], total: el[:march] },
        { name: 'April', balance: el[:april], total: el[:april] },
        { name: 'May', balance: el[:may], total: el[:may] },
        { name: 'June', balance: el[:june], total: el[:june] },
        { name: 'July', balance: el[:july], total: el[:july] },
        { name: 'August', balance: el[:august], total: el[:august] },
        { name: 'September', balance: el[:september], total: el[:september] },
        { name: 'October', balance: el[:october], total: el[:october] },
        { name: 'November', balance: el[:november], total: el[:november] },
        { name: 'December', balance: el[:december], total: el[:december] },
      ],
      children: el[:children].map { |c| process_line(c) }
    }

    line[:total] += line[:children].sum { |x| x[:total] }

    12.times do |i|
      line[:months][i][:total] += line[:children].sum { |x| x[:months][i][:total] }
    end

    line
  end
end
