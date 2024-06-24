# frozen_string_literal: true

class WebhooksController < ActionController::API
  # since we are using ActionController::API as a base class, CSRF protection is not included in it
  # and there is no need to disable it for webhooks controller

  # curl -X POST http://localhost:3000/webhooks -H "Content-Type: application/json" -d '{"event": "application_hired"}'
  def create
    return head :bad_request unless verify_request

    received_webhook = ReceivedWebhook.find_or_initialize_by(payload:)

    if received_webhook.new_record?
      received_webhook.save
      WebhookHandlerJob.perform_later(received_webhook)
    end

    head :ok
  end

  private

  def verify_request
    # adding :fail_verification param allows to simulate failed verification
    params[:fail_verification].blank?
  end

  def payload
    parsed = JSON.parse(request.body.read)
    JSON.generate(parsed)
  end
end
