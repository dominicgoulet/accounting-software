# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  id                :uuid             not null, primary key
#  user_id           :uuid             not null
#  organization_id   :uuid             not null
#  level             :string
#  confirmed_at      :datetime
#  last_logged_in_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Membership < ApplicationRecord
  extend Enumerize

  # Associations
  belongs_to :user
  belongs_to :organization
  has_many :role_members
  has_many :roles, through: :role_members

  # Validations
  validates :user, presence: true
  validates :organization, presence: true

  # Enumerations
  enumerize :level, in: %i[owner admin member], default: :member

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  broadcasts_to lambda { |membership|
                  [membership.organization, :memberships]
                }, inserts_by: :prepend, partial: 'settings/memberships/membership'

  after_commit :send_html_counter, on: %i[create destroy]
  def send_html_counter
    broadcast_update_to [organization, :count],
                        target: 'members-count',
                        html: organization.memberships.size
  end

  #
  # Shorthands
  #

  def display_name
    user.display_name
  end

  def classification; end

  #
  # Confirmation
  #

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    return false if confirmed?

    update(confirmed_at: Time.zone.now)
  end

  private

  def can_update?
    true
  end

  def can_delete?
    return true if destroyed_by_association.present?
    return true unless level.owner?

    errors.add(:id, 'cannot delete')
    throw(:abort)
  end
end
