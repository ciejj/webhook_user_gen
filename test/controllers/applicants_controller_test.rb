# frozen_string_literal: true

require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def setup
    @payload = load_test_fixture('applicant_hired.json').to_json
  end

  test 'should consume webhook, create received_webhook record and enqueue job' do
    assert_difference 'ReceivedWebhook.count' do
      post webhooks_url, params: @payload, headers: { 'Content-Type': 'application/json' }
    end
    assert_enqueued_jobs 1
    assert_response :ok
  end

  test 'should not consume webhook, when verification fails' do
    assert_no_difference 'ReceivedWebhook.count' do
      post webhooks_url(fail_verification: 1), params: @payload,
                                                          headers: { 'Content-Type': 'application/json' }
    end
    assert_enqueued_jobs 0
    assert_response :bad_request
  end

  test 'should enqueue only one job despite multiple same requests' do
    assert_difference 'ReceivedWebhook.count', 1 do
      2.times do
        post webhooks_url, params: @payload, headers: { 'Content-Type': 'application/json' }
      end
    end

    assert_enqueued_jobs 1

    assert_response :ok
  end

  private

  def load_test_fixture(filename)
    file_path = Rails.root.join('test', 'fixtures', 'webhooks', filename)
    JSON.parse(File.read(file_path))
  end
end
