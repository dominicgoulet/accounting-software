# frozen_string_literal: true

# == Schema Information
#
# Table name: business_units
#
#  id                      :uuid             not null, primary key
#  description             :string
#  full_path               :string
#  internal_code           :string
#  name                    :string
#  system                  :boolean          default(FALSE)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organization_id         :uuid
#  parent_business_unit_id :uuid
#
class BusinessUnit < ApplicationRecord
  # Associations
  belongs_to :organization
  belongs_to :parent_business_unit, class_name: 'BusinessUnit', optional: true
  has_many :permissions, dependent: :destroy
  has_many :child_business_units, class_name: 'BusinessUnit', foreign_key: 'parent_business_unit_id',
                                  dependent: :nullify

  # Validations
  validates :organization, presence: true
  validates :name, presence: true
  validate :parent_business_unit_cannot_be_itself_or_a_child

  # Callbacks
  after_create :setup_permissions
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  before_save :update_full_path
  after_save :update_child_business_units
  before_destroy :update_child_business_units

  # Scope
  default_scope { order(:full_path) }

  # Hotwired
  broadcasts_to lambda { |business_unit|
                  [business_unit.organization, :business_units]
                }, inserts_by: :prepend, partial: 'settings/business_units/business_unit'

  after_commit :send_html_counter, on: %i[create destroy]
  def send_html_counter
    broadcast_update_to [organization, :count],
                        target: 'business-units-count',
                        html: organization.business_units.size
  end

  #
  # Shorthands
  #

  def display_name
    name
  end

  def classification; end

  #
  # Parent
  #

  def parent_business_units
    parents = []

    acc = parent_business_unit

    while acc
      parents << acc

      acc = acc.parent_business_unit
    end

    parents.reverse
  end

  private

  def update_full_path
    self.full_path = (parent_business_units.map(&:display_name) + [display_name]).join('.')
  end

  def setup_permissions
    Permission.init_permissions_for_organization(organization)
  end

  def parent_business_unit_cannot_be_itself_or_a_child
    return unless parent_business_unit.present?

    if parent_business_unit == self
      errors.add(:parent_business_unit, 'cannot be self.')
      throw(:abort)
    elsif parent_business_unit.parent_business_unit.present?
      bu = parent_business_unit.parent_business_unit

      while bu.present?
        if bu == self
          errors.add(:parent_business_unit, 'cannot be a child of this business unit.')
          throw(:abort)
        end

        bu = bu.parent_business_unit
      end
    end

    true
  end

  def update_child_business_units
    child_business_units.each(&:save)
  end

  def can_update?
    true
  end

  def can_delete?
    return true if destroyed_by_association.present?
    return true unless system?

    errors.add(:system, 'cannot delete')
    throw(:abort)
  end
end
