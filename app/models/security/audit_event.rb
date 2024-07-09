# frozen_string_literal: true

# == Schema Information
#
# Table name: audit_events
#
#  id              :uuid             not null, primary key
#  action          :string
#  auditable_type  :string
#  current_value   :jsonb
#  occured_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  auditable_id    :uuid
#  integration_id  :uuid             not null
#  organization_id :uuid             not null
#  user_id         :uuid
#
class AuditEvent < ApplicationRecord
  extend Enumerize

  # Associations
  belongs_to :integration
  belongs_to :organization
  belongs_to :auditable, polymorphic: true
  belongs_to :user, optional: true

  # Validations
  validates_presence_of :integration
  validates_presence_of :organization
  validates_presence_of :auditable
  validates_presence_of :action

  # Enumerations
  enumerize :action, in: %i[create update destroy]

  # Callbacks
  before_save :set_current_value
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  broadcasts_to lambda { |audit_event|
                  [audit_event.organization, :audit_events]
                }, inserts_by: :prepend, partial: 'audit_events/audit_event'

  #
  # Version control
  #

  def changes_from_previous_version
    previous_version = integration.audit_events.where(
      auditable_id:,
      auditable_type:,
      occured_at: ..occured_at
    ).where.not(id:).order('occured_at desc').first

    skipped_fields = %w[id organization_id contact_id created_at updated_at]

    was = previous_version.present? ? JSON.parse(previous_version.current_value) : {}
    is = JSON.parse(current_value)

    diff = []

    is.each_key do |key|
      diff << { property: key, was: was[key], is: is[key] } if !skipped_fields.include?(key) && was[key] != is[key]
    end

    diff
  end

  private

  def set_current_value
    self.current_value = auditable.to_json
  end

  def can_update?
    errors.add(:id, 'cannot update')
    throw(:abort)
  end

  def can_delete?
    errors.add(:id, 'cannot delete')
    throw(:abort)
  end
end
