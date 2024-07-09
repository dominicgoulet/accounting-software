# frozen_string_literal: true

class CustomIntegration < CoreIntegration
  def generate_journal_entry(date, journalable_id, journalable_type, lines)
    journal_entry = @organization.journal_entries.find_or_create_by(
      journalable_id:,
      journalable_type:,
      integration_id: @integration.id
    )

    journal_entry.update(date:)

    journal_entry.journal_entry_lines.delete_all
    journal_entry.journal_entry_lines << lines
    journal_entry.save
  end

  def remove_journal_entry(journalable_id, journalable_type)
    @organization.journal_entries.find_by(
      journalable_id:,
      journalable_type:,
      integration_id: @integration.id
    )&.destroy
  end
end
