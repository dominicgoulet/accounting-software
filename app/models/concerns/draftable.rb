# frozen_string_literal: true

module Draftable
  extend ActiveSupport::Concern

  def accept_draft!
    update(status: self.class.status.values[1])
  end

  def return_to_draft!
    update(status: 'draft')
  end
end
