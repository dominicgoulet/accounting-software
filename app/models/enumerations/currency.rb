# frozen_string_literal: true

class Currency
  attr_accessor :code, :name

  def initialize(code, name)
    self.code = code
    self.name = name
  end

  def self.values
    [
      Currency.new('CAD', 'Canadian Dollar'),
      Currency.new('USD', 'United-State Dollar')
    ]
  end
end
