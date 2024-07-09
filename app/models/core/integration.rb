# frozen_string_literal: true

# == Schema Information
#
# Table name: integrations
#
#  id                    :uuid             not null, primary key
#  internal_code         :string
#  name                  :string
#  secret_key_bidx       :string
#  secret_key_ciphertext :text
#  subscribed_webhooks   :string           default([]), is an Array
#  system                :boolean          default(FALSE)
#  webhook_url           :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  organization_id       :uuid             not null
#
class Integration < ApplicationRecord
  has_encrypted :secret_key
  blind_index :secret_key

  #
  # Integrations are the backbone of inter-system communication.
  #   - Generate API keys (so other systems can query & push data to ninetyfour)
  #   - Setup Webhooks (for automatic update deliveries to external systems)

  # Associations
  belongs_to :organization
  has_many :journal_entries
  has_many :audit_events
  has_many_attached :attached_files

  # Callbacks
  before_create :generate_secret_key
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Validations
  validates :organization, presence: true
  validates :name, presence: true
  validates :secret_key, uniqueness: true, allow_blank: true

  # Hotwired
  broadcasts_to lambda { |integration|
                  [integration.organization, :integrations]
                }, inserts_by: :prepend, partial: 'settings/integrations/integration'

  def log_event(auditable, action, user = nil)
    audit_event = audit_events.build(
      organization:,
      user:,
      auditable:,
      action:,
      occured_at: DateTime.now
    )

    audit_event.save
  end

  def self.available_webhooks
    [
      Webhook.new('JOURNAL_ENTRY_CREATED', 'New journal entry'),
      Webhook.new('JOURNAL_ENTRY_DESTROYED', 'Removed journal entry'),
      Webhook.new('JOURNAL_ENTRY_UPDATED', 'Updated journal entry')
    ]
  end

  def setup_specific_integration(integration_type)
    case integration_type
    when 'NINETYFOUR' then self.internal_code = 'NINETYFOUR'
    when 'QUICKBOOKS' then self.internal_code = 'QUICKBOOKS'
    when 'XERO' then self.internal_code = 'XERO'
    end
  end

  def icon
    case internal_code
    when 'NINETYFOUR' then 'integrations/ninetyfour'
    when 'QUICKBOOKS' then 'integrations/quickbooks'
    when 'XERO' then 'integrations/xero'
    else 'integrations/custom'
    end
  end

  def journalable_types
    sql = %(
      SELECT DISTINCT journalable_type
        FROM journal_entries
       WHERE journal_entries.integration_id = '#{id}'
    ORDER BY journalable_type ASC
    )

    report = []

    ActiveRecord::Base.connection.exec_query(sql).rows.each do |row|
      report << row[0]
    end

    report
  end

  private

  def generate_secret_key
    self.secret_key = "sk_#{SecureRandom.hex}" if secret_key.nil?
  end

  def can_update?
    return true unless system?

    errors.add(:system, 'cannot update')
    throw(:abort)
  end

  def can_delete?
    return true unless system? || journal_entries.size > 0

    errors.add(:system, 'cannot delete')
    throw(:abort)
  end
end
