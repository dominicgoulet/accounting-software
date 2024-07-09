# frozen_string_literal: true

# == Schema Information
#
# Table name: recurring_events
#
#  id              :uuid             not null, primary key
#  day_of_month    :integer          default([]), is an Array
#  day_of_week     :integer          default([]), is an Array
#  day_of_year     :integer          default([]), is an Array
#  end_repeat      :string
#  frequency       :string
#  interval        :integer
#  month_of_year   :integer          default([]), is an Array
#  recurrable_type :string
#  repeat_count    :integer
#  repeat_until    :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  recurrable_id   :uuid
#
class RecurringEvent < ApplicationRecord
  extend Enumerize

  # Associations
  belongs_to :organization
  belongs_to :recurrable, polymorphic: true

  # Validations
  validates :organization, presence: true
  validates :frequency, presence: true

  # Shoudl validate arrays
  # validates :day_of_week, numericality: { only_integer: true, in: 1..7, other_than: 0 }, allow_blank: true
  # validates :day_of_month, numericality: { only_integer: true, in: -1..31, other_than: 0 }, allow_blank: true
  # validates :day_of_year, numericality: { only_integer: true, in: -1..366, other_than: 0 }, allow_blank: true
  # validates :month_of_year, numericality: { only_integer: true, in: 1..12 }, allow_blank: true

  # Enumerations
  enumerize :frequency, in: %i[daily weekly monthly yearly], default: :monthly
  enumerize :end_repeat, in: %i[never count date], default: :never

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  # broadcasts_to ->(recurring_event) { [recurring_event.organization, :recurring_events] }, inserts_by: :prepend

  private

  def can_update?
    true
  end

  def can_delete?
    true
  end
end
