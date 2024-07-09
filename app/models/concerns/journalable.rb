# frozen_string_literal: true

module Journalable
  extend ActiveSupport::Concern

  included do
    after_save :update_journal_entry
    before_destroy :destroy_journal_entry
  end

  private

  def journalable_type
    self.class.base_class.name
  end

  def ninetyfour_integration
    integration = organization.integrations.find_by(system: true, internal_code: 'NINETYFOUR')
    NinetyfourIntegration.new(integration)
  end

  def update_journal_entry
    if status != 'draft'
      ninetyfour_integration.generate_journal_entry(date, id, journalable_type)
    else
      ninetyfour_integration.remove_journal_entry(id, journalable_type)
    end
  end

  def destroy_journal_entry
    ninetyfour_integration.remove_journal_entry(id, journalable_type)
  end
end
