# frozen_string_literal: true

class WebhookHandlerJob < ApplicationJob
  queue_as :default

  attr_reader :received_webhook, :parsed_payload

  def perform(received_webhook)
    @received_webhook = received_webhook
    @parsed_payload = parse_payload

    process_webhook
  end

  private

  def parse_payload
    JSON.parse(received_webhook.payload, symbolize_names: true)
  end

  def process_webhook
    case parsed_payload.dig(:event)
    when 'application_hired'
      handle_application_hired_event
    else
      received_webhook.update!(status: :skipped, error: "unknown event: #{parsed_payload.dig(:event)}")
    end
  end

  def handle_application_hired_event
    application_id = parsed_payload.dig(:data, :application, :id)
    return received_webhook.update!(status: :skipped, error: 'missing application_id') unless application_id

    create_new_employee_service = Services::HireApplicant.new(application_id:)

    unless create_new_employee_service.call
      return received_webhook.update!(status: :failed,
                                      error: create_new_employee_service.error)
    end

    received_webhook.update!(status: :processed, execution_details: create_new_employee_service.execution_details)
  end
end
