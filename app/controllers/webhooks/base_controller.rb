# frozen_string_literal: true

module Webhooks
  class BaseController < ApplicationController
    # since we are using ActionController::API as a base class, CSRF protection is not included in it
    # and there is no need to disable it for webhooks controller

    before_action :verify_request

    def create
      ReceivedWebhook.create!(payload:)
      head :ok
    end

    private

    def verify_request
      head :bad_request
    end

    def payload
      @payload ||= request.body.read
    end
  end
end
