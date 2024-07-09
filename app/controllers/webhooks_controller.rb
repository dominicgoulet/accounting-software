# frozen_string_literal: true

class WebhooksController < ActionController::Base
  def plaid
    logger.debug '============================================='
    logger.debug 'WebhooksController # PLAID'
    logger.debug ''
    logger.debug "params: #{params}"
    logger.debug ''
    logger.debug '============================================='

    head :no_content
  end
end
