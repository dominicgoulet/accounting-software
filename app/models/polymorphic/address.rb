# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id                 :uuid             not null, primary key
#  addressable_type   :string
#  city               :string
#  country            :string
#  line1              :string
#  line2              :string
#  state_or_province  :string
#  zip_or_postal_code :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  addressable_id     :uuid
#
class Address < ApplicationRecord
  # Associations
  belongs_to :addressable, polymorphic: true

  # Validations
  validates :addressable, presence: true

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
