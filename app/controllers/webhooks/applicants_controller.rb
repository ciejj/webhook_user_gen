# frozen_string_literal: true

module Webhooks
  class ApplicantsController < Webhooks::BaseController
    def create
      received_webhook = ReceivedWebhook.create!(payload:)
      Webhooks::ApplicantsJob.perform_later(received_webhook)
      head :ok
    end

    private

    def verify_request
      head :bad_request if params[:fail_verification]
    end
  end
end
