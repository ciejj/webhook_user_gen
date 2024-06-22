# frozen_string_literal: true

module Webhooks
  class ApplicantsJob < ApplicationJob
    queue_as :default

    def perform(received_webhook)
      _parsed_payload = JSON.parse(
        received_webhook.payload,
        symbolize_names: true
      )

      case parsed_payload[:event]
      when "application_hired"
        # do something - call the main service
        received_webhook.update!(status: :processed)
      else
        received_webhook.update!(status: :skipped)
      end
    end
  end
end
