class SalesTaxReport < Report
  #
  # Fields
  #

  F_TAX_ID = 0
  F_TAX_NAME = 1
  F_STARTING_BALANCE = 2
  F_NET_SALES_DURING_PERIOD = 3
  F_TAX_AMOUNT_ON_SALES_DURING_PERIOD = 4
  F_NET_PURCHASE_SDURING_PERIOD = 5
  F_TAX_AMOUNT_ON_PURCHASES_DURING_PERIOD = 6
  F_NET_TAX_OWING_FOR_PERIOD = 7
  F_PAYMENTS_TO_GOVERNEMENT_DURING_PERIOD = 8
  F_ENDING_BALANCE = 9

  def query_parameters_components
    [
      ReportQueryParameters::PeriodOfTimeComponent.new(self.organization_id, self.start_date, self.end_date),
      # ReportQueryParameters::BusinessUnitsComponent.new(self.organization_id, self.business_unit_id),
      # ReportQueryParameters::IntegrationsComponent.new(self.organization_id, self.integration_id)
    ]
  end

  # => 1) Starting Balance (As Of FROM_DATE)
  # => 2) Net Sales During Period
  # => 3) Tax Amount On Sales During Period (CREDIT Between FROM_DATE And TO_DATE)
  # => 4) Net Purchases During Period
  # => 5) Tax Amount On Purchases During Period (DEBIT Between FROM_DATE And TO_DATE)
  # => 6) Net Tax Owing For Period (=3-5)
  # => 7) Less Payments To Governement During Period (Between FROM_DATE And TO_DATE)
  # => 8) Ending Balance (As Of TO_DATE)

  def execute
    sql = ActiveRecord::Base::sanitize_sql([%{
      SELECT TaxId,
             TaxName,
             SUM(StartingBalance),
             SUM(NetSalesDuringPeriod),
             SUM(TaxAmountOnSalesDuringPeriod),
             SUM(NetPurchasesDuringPeriod),
             SUM(TaxAmountOnPurchasesDuringPeriod),
             SUM(TaxAmountOnSalesDuringPeriod) - SUM(TaxAmountOnPurchasesDuringPeriod) AS NetTaxOwingForPeriod,
             SUM(PaymentsToGovernementDuringPeriod),
             SUM(StartingBalance) + SUM(TaxAmountOnSalesDuringPeriod) - SUM(TaxAmountOnPurchasesDuringPeriod) - SUM(PaymentsToGovernementDuringPeriod) AS EndingBalance

        FROM (

                SELECT accounts.id AS TaxId,
                       accounts.name AS TaxName,
                       SUM(credit) - SUM(debit) AS StartingBalance,
                       0 AS NetSalesDuringPeriod,
                       0 AS TaxAmountOnSalesDuringPeriod,
                       0 AS NetPurchasesDuringPeriod,
                       0 AS TaxAmountOnPurchasesDuringPeriod,
                       0 AS PaymentsToGovernementDuringPeriod
                  FROM accounts
             LEFT JOIN (journal_entry_lines
                            INNER JOIN journal_entries
                                    ON journal_entry_lines.journal_entry_id = journal_entries.id
                                   AND journal_entries.date < ?)
                    ON accounts.id = journal_entry_lines.account_id

                 WHERE accounts.accountable_type = 'SalesTax'
                   AND accounts.organization_id = ?
              GROUP BY accounts.id, accounts.name

             UNION ALL

                SELECT accounts.id AS TaxId,
                       accounts.name AS TaxName,
                       0 AS StartingBalance,
                       (
                          SELECT SUM(credit)
                            FROM journal_entry_lines
                      INNER JOIN accounts on journal_entry_lines.account_id = accounts.id
                           WHERE journal_entry_lines.journal_entry_id IN (
                                   SELECT journal_entry_lines.journal_entry_id
                                     FROM accounts
                               INNER JOIN journal_entry_lines ON accounts.id = journal_entry_lines.account_id
                                    WHERE accounts.accountable_type = 'SalesTax'
                                      AND accounts.organization_id = ?
                                 )
                             AND accounts.classification IN ('income')
                             AND accounts.organization_id = ?
                       ) AS NetSalesDuringPeriod,
                       SUM(credit) AS TaxAmountOnSalesDuringPeriod,
                       (
                          SELECT SUM(debit)
                            FROM journal_entry_lines
                      INNER JOIN accounts on journal_entry_lines.account_id = accounts.id
                           WHERE journal_entry_lines.journal_entry_id IN (
                                   SELECT journal_entry_lines.journal_entry_id
                                     FROM accounts
                               INNER JOIN journal_entry_lines ON accounts.id = journal_entry_lines.account_id
                                    WHERE accounts.accountable_type = 'SalesTax'
                                      AND accounts.organization_id = ?
                                 )
                             AND accounts.classification IN ('expense')
                             AND accounts.organization_id = ?
                       ) AS NetPurchasesDuringPeriod,
                       SUM(debit) AS TaxAmountOnPurchasesDuringPeriod,
                       0 AS PaymentsToGovernementDuringPeriod
                  FROM accounts
             LEFT JOIN (journal_entry_lines
                            INNER JOIN journal_entries
                                    ON journal_entry_lines.journal_entry_id = journal_entries.id
                                   AND journal_entries.date BETWEEN ? AND ?)
                    ON accounts.id = journal_entry_lines.account_id

                 WHERE accounts.accountable_type = 'SalesTax'
                   AND accounts.organization_id = ?
              GROUP BY accounts.id, accounts.name

             ) As SubQuery
    GROUP BY TaxId,
             TaxName

    },
      start_date,
      self.organization_id,
      self.organization_id,
      self.organization_id,
      self.organization_id,
      self.organization_id,
      start_date,
      end_date,
      self.organization_id,
    ])

    report = {
      taxes: [],
      total: nil
    }

    ActiveRecord::Base.connection.exec_query(sql).rows.each do |row|
      report[:taxes] << {
        TaxId: row[F_TAX_ID],
        TaxName: row[F_TAX_NAME],
        StartingBalance: row[F_STARTING_BALANCE],
        NetSalesDuringPeriod: row[F_NET_SALES_DURING_PERIOD],
        TaxAmountOnSalesDuringPeriod: row[F_TAX_AMOUNT_ON_SALES_DURING_PERIOD],
        NetPurchasesDuringPeriod: row[F_NET_PURCHASE_SDURING_PERIOD],
        TaxAmountOnPurchasesDuringPeriod: row[F_TAX_AMOUNT_ON_PURCHASES_DURING_PERIOD],
        NetTaxOwingForPeriod: row[F_NET_TAX_OWING_FOR_PERIOD],
        PaymentsToGovernementDuringPeriod: row[F_PAYMENTS_TO_GOVERNEMENT_DURING_PERIOD],
        EndingBalance: row[F_ENDING_BALANCE]
      }
    end

  report[:total] = {
      TaxId: nil,
      TaxName: 'Total',
      StartingBalance: report[:taxes].sum { |x| x[:StartingBalance] },
      NetSalesDuringPeriod: nil,
      TaxAmountOnSalesDuringPeriod: report[:taxes].sum { |x| x[:TaxAmountOnSalesDuringPeriod] },
      NetPurchasesDuringPeriod: nil,
      TaxAmountOnPurchasesDuringPeriod: report[:taxes].sum { |x| x[:TaxAmountOnPurchasesDuringPeriod] },
      NetTaxOwingForPeriod: report[:taxes].sum { |x| x[:NetTaxOwingForPeriod] },
      PaymentsToGovernementDuringPeriod: report[:taxes].sum { |x| x[:PaymentsToGovernementDuringPeriod] },
      EndingBalance: report[:taxes].sum { |x| x[:EndingBalance] },
    }

    report
  end
end
