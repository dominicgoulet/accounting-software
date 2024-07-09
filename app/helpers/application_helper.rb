# frozen_string_literal: true

module ApplicationHelper
  def render_turbo_stream_flash_messages
    turbo_stream.prepend 'flash', partial: 'partials/flash'
  end

  def form_error_notification(form, field)
    return unless form.object.errors.any?

    tag.div class: 'text-red-500 absolute font-normal text-xs ml-px mt-1' do
      form.object.errors.full_messages_for(field).to_sentence.capitalize
    end
  end

  def time_from_now(date)
    if date == Date.today
      'today'
    elsif date > Date.today
      "in #{time_ago_in_words date}"
    else
      "#{time_ago_in_words date} ago"
    end
  end

  def format_amount(amount)
    amount = 0 unless amount.present?
    "$ #{number_to_currency(amount, unit: '', separator: '.', delimiter: ' ')}"
  end

  def format_amount_condensed(amount)
    amount = 0 unless amount.present?
    "#{number_to_currency(amount, unit: '', separator: '.', delimiter: ' ', negative_format: "(%u%n)")}"
  end

  def page_header(model, title)
    tag.header class: 'flex mb-8 items-center h-10' do
      page_title(title) +
        page_new_button(model)
    end
  end

  def page_title(title)
    tag.h1 class: 'text-3xl font-extralight text-slate-600 grow' do
      title
    end
  end

  def page_new_button(model)
    button_to new_polymorphic_path(model),
              method: :get,
              class: 'btn btn-primary',
              data: { turbo_frame: :modal } do
      inline_svg_tag 'plus'
    end
  end

  def master_checkbox
    tag.input type: 'checkbox',
              class: 'absolute left-4 top-1/2 -mt-2 h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 sm:left-6',
              data: { datatable_target: 'masterCheckbox', action: 'click->datatable#checkAll' }
  end

  def children_checkbox(value, top=false)
    tag.input type: 'checkbox',
              name: 'item_ids[]',
              value:,
              checked: false,
              class: "#{top ? 'mt-3.5' : 'top-1/2 -mt-2'} absolute left-4 h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500 sm:left-6",
              data: { datatable_target: 'childrenCheckbox', action: 'click->datatable#updateTargets' }
  end

  def status_badge(status)
    tag.span class: "inline-flex items-center rounded bg-#{status_color(status)}-100 px-2 py-0.5 text-xs font-medium text-#{status_color(status)}-800" do
      status
    end
  end

  def empty_state
    tag.div class: 'empty-state' do
      inline_svg_tag('logo-mono') +
        tag.h2 do
          'Nothing to see here!'
        end
    end
  end

  def current_controllers?(path, names)
    return true if request.path == path

    names.each do |name|
      return true if current_controller?(name)
    end

    false
  end

  def status_color(status)
    {
      draft: 'gray',
      new: 'indigo',
      sent: 'cyan',
      late: 'red',
      incomplete: 'red',
      paid: 'green',

      imported: 'gray',
      matched: 'indigo',
      described: 'cyan',
      approved: 'green',
      rejected: 'red',

      pending: 'yellow',
      won: 'green',
      lost: 'red',

      accepted: 'cyan',
      completed: 'green',
    }[(status || '').to_sym]
  end

  def main_menu_items
    [
      {
        path: transactions_path,
        controllers: %w[transactions bank_transaction_rules],
        icon: 'building-library',
        title: t('menus.main.transactions')
      },
      {
        path: people_path,
        controllers: ['contacts'],
        icon: 'users',
        title: t('menus.main.people')
      },
      {
        path: documents_path,
        controllers: %w[commercial_documents],
        icon: 'currency-dollar',
        title: t('menus.main.documents')
      },
      {
        path: reports_path,
        controllers: ['reports'],
        icon: 'chart-bar',
        title: t('menus.main.reports')
      },
      {
        path: ledger_path,
        controllers: ['journal_entries'],
        icon: 'book-open',
        title: t('menus.main.ledger')
      },
      # {
      #   path: shoebox_path,
      #   controllers: ['shoebox'],
      #   icon: 'outline/archive-box',
      #   title: t('menus.main.shoebox')
      # },
      # {
      #   path: auditor_path,
      #   controllers: ['auditor'],
      #   icon: 'scale',
      #   title: t('menus.main.auditor')
      # }
    ]
  end

  def people_menu_items
    [
      # {
      #   path: people_path,
      #   controller: 'contacts',
      #   icon: 'outline/list-bullet',
      #   label: 'All contacts'
      # },
      {
        path: contacts_path,
        controller: 'contacts',
        icon: 'outline/list-bullet',
        label: 'Contacts'
      },
      {
        path: members_organization_path(current_organization),
        controller: 'organizations',
        icon: 'outline/list-bullet',
        label: 'Employees'
      },
      # {
      #   path: customers_contacts_path,
      #   controller: 'contacts',
      #   icon: 'outline/list-bullet',
      #   label: 'Customers'
      # },
      # {
      #   path: suppliers_contacts_path,
      #   controller: 'contacts',
      #   icon: 'outline/list-bullet',
      #   label: 'Suppliers'
      # },
      # {
      #   path: employees_contacts_path,
      #   controller: 'contacts',
      #   icon: 'outline/list-bullet',
      #   label: 'Employees'
      # }
    ]
  end

  def transactions_menu_items
    [
      {
        path: transactions_path,
        controller: 'transactions',
        icon: 'outline/list-bullet',
        label: 'Transactions'
      },
      # {
      #   path: bank_transaction_rules_path,
      #   controller: 'bank_transaction_rules',
      #   icon: 'outline/cog-8-tooth',
      #   label: 'Rules & automation'
      # },
      {
        path: bank_credentials_path,
        controller: 'bank_credentials',
        icon: 'outline/building-library',
        label: 'Bank credentials'
      }
    ]
  end

  def accounting_menu_items
    [
      {
        path: ledger_path,
        controller: 'journal_entries',
        icon: 'outline/list-bullet',
        label: 'Journal'
      },
      {
        path: accounts_path,
        controller: 'accounts',
        icon: 'outline/building-library',
        label: 'Chart of accounts'
      },
      {
        path: integrations_path,
        controller: 'integrations',
        icon: 'outline/rectangle-group',
        label: 'Integrations'
      },
      {
        path: business_units_organization_path(current_organization),
        controller: 'organizations',
        icon: 'outline/building-office',
        label: 'Business units'
      },
    ]
  end

  def documents_menu_items
    [
      # {
      #   path: documents_path,
      #   controller: 'app',
      #   icon: 'outline/inbox-stack',
      #   label: t('menus.main.documents')
      # },
      {
        path: invoices_path,
        controller: 'invoices',
        icon: 'outline/currency-dollar',
        label: t('menus.main.invoices')
      },
      {
        path: bills_path,
        controller: 'bills',
        icon: 'outline/credit-card',
        label: t('menus.main.bills')
      },
      {
        path: deposits_path,
        controller: 'deposits',
        icon: 'outline/banknotes',
        label: t('menus.main.deposits')
      },
      {
        path: expenses_path,
        controller: 'expenses',
        icon: 'outline/receipt-percent',
        label: t('menus.main.expenses')
      },
      # {
      #   path: estimates_path,
      #   controller: 'estimates',
      #   icon: 'outline/document-text',
      #   label: t('menus.main.estimates')
      # },
      # {
      #   path: purchase_orders_path,
      #   controller: 'purchase_orders',
      #   icon: 'outline/shopping-cart',
      #   label: t('menus.main.purchase_orders')
      # }
    ]
  end

  def reports_menu_items
    [
      # {
      #   path: overview_reports_path,
      #   icon: 'outline/chart-pie',
      #   title: t('menus.reports.overview.title'),
      #   label: t('menus.reports.overview.description')
      # },
      {
        path: balance_sheet_reports_path,
        icon: 'outline/scale',
        title: t('menus.reports.balance_sheet.title'),
        label: t('menus.reports.balance_sheet.description')
      },
      {
        path: profit_and_loss_reports_path,
        icon: 'outline/chart-bar',
        title: t('menus.reports.profit_and_loss.title'),
        label: t('menus.reports.profit_and_loss.description')
      },
      # {
      #   path: cashflow_reports_path,
      #   icon: 'outline/currency-dollar',
      #   title: t('menus.reports.cashflow.title'),
      #   label: t('menus.reports.cashflow.description')
      # },
      # {
      #   path: account_payable_aging_reports_path,
      #   icon: 'outline/arrow-trending-up',
      #   title: t('menus.reports.account_payable_aging.title'),
      #   label: t('menus.reports.account_payable_aging.description')
      # },
      # {
      #   path: account_receivable_aging_reports_path,
      #   icon: 'outline/arrow-trending-down',
      #   title: t('menus.reports.account_receivable_aging.title'),
      #   label: t('menus.reports.account_receivable_aging.description')
      # },
      {
        path: sales_tax_reports_path,
        icon: 'outline/receipt-percent',
        title: t('menus.reports.sales_tax.title'),
        label: t('menus.reports.sales_tax.description')
      }
    ]
  end

  def settings_menu_items
    [
      {
        path: accounts_path,
        controller: 'accounts',
        icon: 'outline/book-open',
        title: t('menus.settings.accounts.title'),
        label: t('menus.settings.accounts.title')
      },
      {
        path: items_path,
        controller: 'items',
        icon: 'outline/archive-box',
        title: t('menus.settings.items.title'),
        label: t('menus.settings.items.title')
      },
      {
        path: sales_taxes_path,
        controller: 'sales_taxes',
        icon: 'outline/receipt-percent',
        title: t('menus.settings.sales_taxes.title'),
        label: t('menus.settings.sales_taxes.title')
      },
      {
        path: bank_credentials_path,
        controller: 'bank_credentials',
        icon: 'outline/building-library',
        title: t('menus.settings.bank_credentials.title'),
        label: t('menus.settings.bank_credentials.title')
      },
      {
        path: integrations_path,
        controller: 'integrations',
        icon: 'outline/rectangle-group',
        title: t('menus.settings.integrations.title'),
        label: t('menus.settings.integrations.title')
      },
      {
        path: organization_path(current_organization),
        controller: 'organizations',
        icon: 'outline/building-office',
        title: t('menus.settings.organizations.title'),
        label: t('menus.settings.organizations.title')
      },
      {
        path: user_path(current_user),
        controller: 'users',
        icon: 'outline/user-circle',
        title: t('menus.settings.users.title'),
        label: t('menus.settings.users.title')
      }
    ]
  end

  def organization_menu_items(organization)
    [
      {
        path: organization_path(organization),
        title: t('menus.organizations.overview.title'),
        description: t('menus.organizations.overview.description')
      },
      {
        path: members_organization_path(organization),
        title: t('menus.organizations.members.title'),
        description: t('menus.organizations.members.description'),
        counter: organization.users.size,
        counter_id: 'members-count'
      },
      # {
      #   path: roles_organization_path(organization),
      #   title: t('menus.organizations.roles.title'),
      #   description: t('menus.organizations.roles.description'),
      #   counter: organization.roles.size,
      #   counter_id: 'roles-count'
      # },
      {
        path: business_units_organization_path(organization),
        title: t('menus.organizations.business_units.title'),
        description: t('menus.organizations.business_units.description'),
        counter: organization.business_units.size,
        counter_id: 'business-units-count'
      },
      # {
      #   path: permissions_organization_path(organization),
      #   title: t('menus.organizations.permissions.title'),
      #   description: t('menus.organizations.permissions.description'),
      #   counter: organization.permissions.size,
      #   counter_id: 'permissions-count'
      # }
    ]
  end

  def contact_menu_items(contact)
    [
      {
        path: contact_path(contact),
        title: t('menus.contact.overview.title'),
        description: t('menus.contact.overview.description')
      },
      {
        path: invoices_contact_path(contact),
        title: t('menus.contact.invoices.title'),
        description: t('menus.contact.invoices.description'),
        counter: contact.invoices.size,
        counter_id: 'invoices-count'
      },
      {
        path: deposits_contact_path(contact),
        title: t('menus.contact.deposits.title'),
        description: t('menus.contact.deposits.description'),
        counter: contact.deposits.size,
        counter_id: 'deposits-count'
      },
      {
        path: bills_contact_path(contact),
        title: t('menus.contact.bills.title'),
        description: t('menus.contact.bills.description'),
        counter: contact.bills.size,
        counter_id: 'bills-count'
      },
      {
        path: expenses_contact_path(contact),
        title: t('menus.contact.expenses.title'),
        description: t('menus.contact.expenses.description'),
        counter: contact.expenses.size,
        counter_id: 'expenses-count'
      }
    ]
  end

  def invoice_menu_items(invoice)
    [
      {
        path: invoice_path(invoice),
        title: t('menus.invoice.overview.title'),
        description: t('menus.invoice.overview.description')
      },
      {
        path: details_invoice_path(invoice),
        title: t('menus.invoice.details.title'),
        description: t('menus.invoice.details.description')
      },
      {
        path: payments_invoice_path(invoice),
        title: t('menus.invoice.payments.title'),
        description: t('menus.invoice.payments.description')
      },
      {
        path: communications_invoice_path(invoice),
        title: t('menus.invoice.communications.title'),
        description: t('menus.invoice.communications.description')
      },
      {
        path: audit_trail_invoice_path(invoice),
        title: t('menus.invoice.audit_trail.title'),
        description: t('menus.invoice.audit_trail.description')
      }
    ]
  end

  def accounts_filters(accounts)
    Account.classification.values.map do |s|
      {
        filter_id: s.to_sym,
        path: accounts_classification_path(s),
        label: t("accounts.classification.#{s}"),
        count: accounts.where(classification: s).size,
        count_id: "filters-#{s}-count"
      }
    end
  end

  def items_filters(items)
    [
      {
        filter_id: :all,
        path: items_kind_path(:all),
        label: t('items.kind.all'),
        count: items.size,
        count_id: 'filters-all-products-or-services-count'
      },
      {
        filter_id: :sell,
        path: items_kind_path(:sell),
        label: t('items.kind.sell'),
        count: items.where(sell: true).size,
        count_id: 'filters-sell-products-or-services-count'
      },
      {
        filter_id: :buy,
        path: items_kind_path(:buy),
        label: t('items.kind.buy'),
        count: items.where(buy: true).size,
        count_id: 'filters-buy-products-or-services-count'
      }
    ]
  end
end
