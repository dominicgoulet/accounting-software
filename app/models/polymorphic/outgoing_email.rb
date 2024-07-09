# frozen_string_literal: true

# == Schema Information
#
# Table name: outgoing_emails
#
#  id                  :uuid             not null, primary key
#  body                :text
#  recipients          :string           default([]), is an Array
#  related_object_type :string
#  subject             :string
#  title               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  organization_id     :uuid
#  related_object_id   :uuid
#
class OutgoingEmail < ApplicationRecord
  # Associations
  belongs_to :organization
  belongs_to :related_object, polymorphic: true, optional: true

  # Validations
  validates :organization, presence: true
  validates :recipients, presence: true
  validates :subject, presence: true

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  def send!
    true
  end

  private

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
