# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id              :uuid             not null, primary key
#  description     :string
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
class Role < ApplicationRecord
  # Associations
  belongs_to :organization
  has_many :permissions, dependent: :destroy
  has_many :role_members, dependent: :destroy
  has_many :memberships, through: :role_members

  # Validations
  validates :organization, presence: true
  validates :name, presence: true

  # Callbacks
  after_create :setup_permissions
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Scope
  default_scope { order(:name) }

  # Hotwired
  broadcasts_to ->(role) { [role.organization, :roles] }, inserts_by: :prepend, partial: 'settings/roles/role'

  after_commit :send_html_counter, on: %i[create destroy]
  def send_html_counter
    broadcast_update_to [organization, :count],
                        target: 'roles-count',
                        html: organization.roles.size
  end

  private

  def setup_permissions
    Permission.init_permissions_for_organization(organization)
  end

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
