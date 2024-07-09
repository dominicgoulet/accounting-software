# frozen_string_literal: true

module Auditable
  extend ActiveSupport::Concern

  # This should audit the following :
  #  1) What changed (property, old value, new value) stored as json
  #       [ { property: 'status', oldValue: 'draft', newValue: 'new' } ]
  #  2) Internal/system comment
  #  3) datetime of when it happned
  #  4) user_id of the person who did the change

  included do
    # Associations
    has_many :audit_events, as: :auditable
  end
end
