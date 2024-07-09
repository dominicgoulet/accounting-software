class BalanceSheetReport < Report
  #
  # Fields
  #

  F_CLASSIFICATION = 0
  F_ID = 1
  F_REFERENCE = 2
  F_NAME = 3
  F_PARENT_ACCOUNT_ID = 4
  F_TOTAL = 5

  def query_parameters_components
    [
      ReportQueryParameters::DateComponent.new(self.organization_id, self.date),
      # ReportQueryParameters::BusinessUnitsComponent.new(self.organization_id, self.business_unit_id),
      # ReportQueryParameters::IntegrationsComponent.new(self.organization_id, self.integration_id)
    ]
  end

  def execute
    start_or_year = Date.new(Date.parse(date).year - 1, 1, 1)

    sql = %{
      SELECT classification,
             id,
             reference,
             name,
             parent_account_id,
             SUM(total),
             CASE classification
             WHEN 'asset' THEN 1
             WHEN 'liability' THEN 2
             WHEN 'equity' THEN 3
             ELSE 999
             END AS rank
        FROM (

              SELECT accounts.classification AS classification,
                     accounts.id AS id,
                     accounts.reference AS reference,
                     accounts.name AS name,
                     accounts.parent_account_id AS parent_account_id,
                     CASE accounts.classification
                     WHEN 'asset' THEN SUM(debit) - SUM(credit)
                     WHEN 'liability' THEN SUM(credit) - SUM(debit)
                     WHEN 'equity' THEN SUM(credit) - SUM(debit)
                     END AS total
                FROM accounts
           LEFT JOIN (journal_entry_lines INNER JOIN journal_entries
                                                  ON journal_entry_lines.journal_entry_id = journal_entries.id
                                                 AND journal_entries.date <= '#{date}')
                      ON accounts.id = journal_entry_lines.account_id
               WHERE accounts.organization_id = '#{organization_id}'
                 AND accounts.classification IN ('asset', 'liability', 'equity')
            GROUP BY accounts.classification,
                     accounts.id,
                     accounts.reference,
                     accounts.name,
                     accounts.parent_account_id

               UNION ALL

              SELECT accounts.classification AS classification,
                     accounts.id AS id,
                     accounts.reference AS reference,
                     accounts.name AS name,
                     accounts.parent_account_id AS parent_account_id,
                     (SELECT SUM(credit) - SUM(debit) AS total
                        FROM accounts
                  LEFT JOIN (journal_entry_lines INNER JOIN journal_entries
                                                  ON journal_entry_lines.journal_entry_id = journal_entries.id
                                                 AND journal_entries.date BETWEEN '#{start_or_year}' AND '#{date}')
                      ON accounts.id = journal_entry_lines.account_id
                       WHERE accounts.organization_id = '#{organization_id}'
                         AND accounts.classification IN ('income', 'expense')) AS total
                FROM accounts
               WHERE accounts.organization_id = '#{organization_id}'
                 AND accounts.internal_code = 'CURRENT_YEAR_EARNINGS'

               UNION ALL

              SELECT accounts.classification AS classification,
                     accounts.id AS id,
                     accounts.reference AS reference,
                     accounts.name AS name,
                     accounts.parent_account_id AS parent_account_id,
                     (SELECT SUM(credit) - SUM(debit) AS total
                        FROM accounts
                   LEFT JOIN (journal_entry_lines INNER JOIN journal_entries
                                                  ON journal_entry_lines.journal_entry_id = journal_entries.id
                                                 AND journal_entries.date < '#{start_or_year}')
                      ON accounts.id = journal_entry_lines.account_id
                       WHERE accounts.organization_id = '#{organization_id}'
                         AND accounts.classification IN ('income', 'expense')) AS total
                FROM accounts
               WHERE accounts.organization_id = '#{organization_id}'
                 AND accounts.internal_code = 'RETAINED_EARNINGS'

              ) AS SubQuery
        GROUP BY classification,
                 id,
                 reference,
                 name,
                 parent_account_id
        ORDER BY rank,
                 reference,
                 name
    }

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
      asset: {
        lines: [],
        total: 0.0,
      },
      liability: {
        lines: [],
        total: 0.0,
      },
      equity: {
        lines: [],
        total: 0.0,
      }
    }

    dict.keys.each do |key|
      el = dict[key]

      report[el[:classification].to_sym][:lines] << process_line(el)
      report[el[:classification].to_sym][:total] += report[el[:classification].to_sym][:lines][-1][:total]
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
      children: el[:children].map { |c| process_line(c) }
    }

    line[:total] += line[:children].sum { |x| x[:total] }

    line
  end
end
