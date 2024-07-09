# frozen_string_literal: true

# == Schema Information
#
# Table name: permissions
#
#  id               :uuid             not null, primary key
#  level            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  business_unit_id :uuid
#  organization_id  :uuid
#  role_id          :uuid
#
class Permission < ApplicationRecord
  extend Enumerize

  # Associations
  belongs_to :organization
  belongs_to :role
  belongs_to :business_unit

  # Validations
  validates :organization, presence: true
  validates :role, presence: true
  validates :business_unit, presence: true

  # Enumerations
  enumerize :level, in: %i[none view edit], default: :none

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  broadcasts_to lambda { |permission|
                  [permission.organization, :permissions]
                }, inserts_by: :prepend, partial: 'settings/permissions/permission'

  after_commit :send_html_counter, on: %i[create destroy]
  def send_html_counter
    broadcast_update_to [organization, :count],
                        target: 'permissions-count',
                        html: organization.permissions.size
  end

  #
  # Shorthands
  #

  def image
    {
      'none' => 'mini/eye-slash',
      'view' => 'mini/eye',
      'edit' => 'mini/pencil-square'
    }.fetch(level, 'mini/question-mark-circle')
  end

  #
  # Level
  #

  def permission_level_none!
    update(level: :none)
  end

  def permission_level_view!
    update(level: :view)
  end

  def permission_level_edit!
    update(level: :edit)
  end

  #
  # Class methods
  #

  def self.init_permissions_for_organization(organization)
    roles = organization.roles.map(&:id)
    business_units = organization.business_units.map(&:id)

    roles.each do |role_id|
      business_units.each do |business_unit_id|
        organization.permissions.find_or_create_by(role_id:, business_unit_id:)
      end
    end
  end

  private

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
