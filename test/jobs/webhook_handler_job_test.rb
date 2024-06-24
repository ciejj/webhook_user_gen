require 'test_helper'

class WebhookHandlerJobTest < ActiveJob::TestCase
  def setup
  end

  test 'should process mark ReceivedWebhook as processed for valid payload, and successful HireApplicant service' do
    @received_webhook = ReceivedWebhook.create!(payload: { event: 'application_hired', data: { application: { id: '12345' }} }.to_json, status: :pending)
    Services::HireApplicant.any_instance.expects(:call).returns(true)

    WebhookHandlerJob.perform_now(@received_webhook)

    assert_equal 'processed', @received_webhook.reload.status
  end

  test 'should process mark ReceivedWebhook as skipped when event type is unknown' do
    @received_webhook = ReceivedWebhook.create!(payload: { event: 'fake_event', data: { application: { id: '12345' }} }.to_json, status: :pending)

    WebhookHandlerJob.perform_now(@received_webhook)

    assert_equal 'skipped', @received_webhook.reload.status
    assert_equal 'unknown event: fake_event', @received_webhook.reload.error
  end

  test 'should process mark ReceivedWebhook as skipped when event is valid, but application_id is missing' do
    @received_webhook = ReceivedWebhook.create!(payload: { event: 'application_hired', data: { } }.to_json, status: :pending)

    WebhookHandlerJob.perform_now(@received_webhook)

    assert_equal 'skipped', @received_webhook.reload.status
    assert_equal 'missing application_id', @received_webhook.reload.error
  end

  test 'should process mark ReceivedWebhook as processed for valid payload, and failed HireApplicant service' do
    @received_webhook = ReceivedWebhook.create!(payload: { event: 'application_hired', data: { application: { id: '12345' }} }.to_json, status: :pending)
    Services::HireApplicant.any_instance.expects(:call).returns(false)
    Services::HireApplicant.any_instance.expects(:error).returns("Error from service")

    WebhookHandlerJob.perform_now(@received_webhook)

    assert_equal 'failed', @received_webhook.reload.status
    assert_equal 'Error from service', @received_webhook.reload.error
  end

end
