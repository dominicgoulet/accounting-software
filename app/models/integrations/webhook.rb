# frozen_string_literal: true

require 'uri'
require 'net/http'

class Webhook
  attr_accessor :id, :name

  def initialize(id, name)
    self.id = id
    self.name = name
  end

  def self.send(integration)
    uri = URI(integration.webhook_url)
    res = Net::HTTP.post_form(uri, 'title' => 'foo', 'body' => 'bar', 'userID' => 1)
    res.body if res.is_a?(Net::HTTPSuccess)
  end
end
