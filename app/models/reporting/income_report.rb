class IncomeReport < Report
  def query_parameters_components
    [
      ReportQueryParameters::PeriodOfTimeComponent.new(self.organization_id),
      ReportQueryParameters::BusinessUnitsComponent.new(self.organization_id),
      ReportQueryParameters::IntegrationsComponent.new(self.organization_id)
    ]
  end

  # ROWS = Customers + TOTAL
  # COLUMNS :
  # => ALL INCOME
  # => PAID INCOME
  # => DUE INCOME

  def execute
    acc = Organization.find(self.organization_id).accounts.find_by(internal_code: 'CURRENT_YEAR_EARNINGS')

    sql = %{
      SELECT *,
             CASE classification
             WHEN 'income' THEN 1
             WHEN 'expense' THEN 2
             ELSE 999
             END AS rank
        FROM (SELECT accounts.classification,
                     accounts.id,
                     accounts.reference,
                     accounts.name,
                     CASE accounts.classification
                     WHEN 'income' THEN SUM(credit) - SUM(debit)
                     WHEN 'expense' THEN SUM(debit) - SUM(credit)
                     END AS total
                FROM accounts
           LEFT JOIN journal_entry_lines ON accounts.id = journal_entry_lines.account_id
               WHERE accounts.organization_id = '#{self.organization_id}'
                 AND accounts.classification IN ('income', 'expense')
            GROUP BY accounts.classification,
                     accounts.id,
                     accounts.reference,
                     accounts.name
               UNION ALL
              SELECT 'earnings' AS classification,
                     NULL AS id,
                     NULL AS reference,
                     NULL AS name,
                     SUM(credit) - SUM(debit) AS total
                FROM accounts
           LEFT JOIN journal_entry_lines ON accounts.id = journal_entry_lines.account_id
               WHERE accounts.organization_id = '#{self.organization_id}'
                 AND accounts.classification IN ('income', 'expense')
              ) AS SubQuery
        ORDER BY rank,
                 reference
    }

    report = []
    last_classification = nil

    ActiveRecord::Base.connection.exec_query(sql).rows.each do |row|
      if last_classification != row[0]
        report << {
          name: row[0],
          total: 0,
          lines: []
        }
      end

      report[-1][:lines] << {
        account: {
          id: row[0] == 'earnings' ? acc.id : row[1],
          reference: row[0] == 'earnings' ? acc.reference : row[2],
          name: row[0] == 'earnings' ? acc.name : row[3]
        },
        total: row[4].to_f
      }

      report[-1][:total] += row[4].to_f

      last_classification = row[0]
    end

    report
  end
end
