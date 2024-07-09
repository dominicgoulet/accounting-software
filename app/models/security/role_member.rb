# frozen_string_literal: true

# == Schema Information
#
# Table name: role_members
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  membership_id :uuid
#  role_id       :uuid
#
class RoleMember < ApplicationRecord
  # Associations
  belongs_to :role
  belongs_to :membership

  # Validations
  validates :role, presence: true
  validates :membership, presence: true

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  private

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
