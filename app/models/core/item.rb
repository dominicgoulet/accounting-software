# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id                 :uuid             not null, primary key
#  buy                :boolean          default(FALSE)
#  buy_description    :string
#  buy_price          :decimal(, )
#  cup                :string
#  name               :string
#  sell               :boolean          default(FALSE)
#  sell_description   :string
#  sell_price         :decimal(, )
#  status             :string
#  ugs                :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  expense_account_id :uuid
#  income_account_id  :uuid
#  organization_id    :uuid             not null
#
class Item < ApplicationRecord
  extend Enumerize

  # Associations
  belongs_to :organization
  belongs_to :income_account, class_name: 'Account', optional: true
  belongs_to :expense_account, class_name: 'Account', optional: true
  has_many :commercial_document_lines

  # Scopes
  default_scope { order(:name) }

  # Validations
  validates :organization, presence: true
  validates :name, presence: true
  validates :income_account, presence: true, if: ->(obj) { obj.sell? }
  validates :expense_account, presence: true, if: ->(obj) { obj.buy? }

  # Enumerations
  enumerize :status, in: %i[active archived], default: :active

  # Callbacks
  before_update :can_update?, prepend: true
  before_destroy :can_delete?, prepend: true

  # Hotwired
  after_create_commit do
    broadcast_prepend_to [organization, :items, :all],
                         inserts_by: :prepend,
                         partial: 'settings/items/item'

    if buy?
      broadcast_prepend_to [organization, :items, :buy],
                           inserts_by: :prepend,
                           partial: 'settings/items/item'
    end

    if sell?
      broadcast_prepend_to [organization, :items, :sell],
                           inserts_by: :prepend,
                           partial: 'settings/items/item'
    end
  end

  after_update_commit do
    broadcast_replace_to [organization, :items],
                         partial: 'settings/items/item'
  end

  after_destroy_commit do
    broadcast_remove_to [organization, :items]
  end

  after_commit :send_html_counter, on: %i[create update destroy]
  def send_html_counter
    broadcast_update_to [organization, :items, :filters],
                        target: 'filters-all-products-or-services-count',
                        html: organization.items.size

    broadcast_update_to [organization, :items, :filters],
                        target: 'filters-buy-products-or-services-count',
                        html: organization.items.where(buy: true).size

    broadcast_update_to [organization, :items, :filters],
                        target: 'filters-sell-products-or-services-count',
                        html: organization.items.where(sell: true).size
  end

  #
  # Shorthands
  #

  def display_name
    name
  end

  private

  def can_update?
    true
  end

  def can_delete?
    return true if destroyed_by_association.present?
    return true unless commercial_document_lines.size.positive?

    errors.add(:id, 'cannot delete')
    throw(:abort)
  end
end
