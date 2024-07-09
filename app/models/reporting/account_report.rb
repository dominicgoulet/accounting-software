class AccountReport < Report
  attr_accessor :account_id

  def initialize(organization_id, account_id)
    self.organization_id = organization_id
    self.account_id = account_id
  end

  def query_parameters_components
    [
      ReportQueryParameters::PeriodOfTimeComponent.new(self.organization_id),
      ReportQueryParameters::BusinessUnitsComponent.new(self.organization_id),
      ReportQueryParameters::IntegrationsComponent.new(self.organization_id)
    ]
  end

  def execute
    sql = %(
      SELECT journal_entries.date,
             COALESCE(CAST(journal_entries.journalable_type AS VARCHAR), journal_entries.integration_journalable_type) AS journalable_type,
             COALESCE(CAST(journal_entries.journalable_id AS VARCHAR), journal_entries.integration_journalable_id) AS journalable_id,
             journal_entry_lines.credit,
             journal_entry_lines.debit,
             accounts.classification,
             integrations.name
        FROM journal_entry_lines
  INNER JOIN journal_entries ON journal_entries.id = journal_entry_lines.journal_entry_id
  INNER JOIN accounts ON accounts.id = journal_entry_lines.account_id
  INNER JOIN integrations ON integrations.id = journal_entries.integration_id
       WHERE accounts.organization_id = '#{organization_id}'
         AND accounts.id = '#{account_id}'
    ORDER BY journal_entries.date ASC
    )

    report = {
      lines: []
    }

    balance = 0

    ActiveRecord::Base.connection.exec_query(sql).rows.each do |row|
      balance += case row[5]
                 when 'expense', 'asset'
                   row[4].to_f - row[3].to_f
                 else
                   row[3].to_f - row[4].to_f
                 end

      report[:lines] << {
        date: row[0],

        journalable_type: (row[1] || '').underscore.humanize,
        journalable_id: row[2],
        # journalable: row[1].constantize.find(row[2]),

        credit: row[3].to_f,
        debit: row[4].to_f,
        balance:,

        integration: row[6]
      }
    end

    report
  end
end
