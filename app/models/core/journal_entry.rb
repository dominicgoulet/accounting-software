# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entries
#
#  id                           :uuid             not null, primary key
#  currency                     :string
#  date                         :date
#  exchange_rate                :decimal(, )
#  integration_journalable_type :string
#  journalable_type             :string
#  narration                    :string
#  total_credit                 :decimal(, )
#  total_debit                  :decimal(, )
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  integration_id               :uuid
#  integration_journalable_id   :string
#  journalable_id               :uuid
#  organization_id              :uuid
#
class JournalEntry < ApplicationRecord
  # Concerns
  include Recurrable

  # Associations
  belongs_to :organization
  belongs_to :integration
  belongs_to :journalable, polymorphic: true, optional: true
  has_many :journal_entry_lines, dependent: :destroy
  has_many_attached :attached_files, dependent: :destroy

  def journalable_type=(class_name)
    super(class_name.constantize.base_class.to_s)
  end

  # Validations
  validates :organization, presence: true
  validates :integration, presence: true
  validates :date, presence: true

  # Callbacks
  before_save :update_calculated_fields
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Nested attributes
  accepts_nested_attributes_for :journal_entry_lines, allow_destroy: true, reject_if: lambda { |c|
                                                                                        c[:account_id].blank?
                                                                                      }

  # Hotwired
  broadcasts_to ->(journal_entry) { [journal_entry.organization, :journal_entries] }, inserts_by: :prepend

  #
  # Shorthands
  #

  def files
    if integration.system? && integration.internal_code == 'NINETYFOUR' && journalable.present?
      return journalable.attached_files
    end

    attached_files
  end

  private

  def update_calculated_fields
    self.total_credit = journal_entry_lines.sum(:credit)
    self.total_debit = journal_entry_lines.sum(:debit)
  end

  def can_update?
    return true # unless journalable.present? && journalable != self

    errors.add(:id, 'cannot update')
    throw(:abort)
  end

  def can_delete?
    return true if destroyed_by_association.present?
    return true unless journalable.present? && journalable != self

    errors.add(:id, 'cannot delete')
    throw(:abort)
  end
end
