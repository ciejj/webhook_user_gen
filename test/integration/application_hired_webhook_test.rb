# frozen_string_literal: true

require 'test_helper'
require 'json'

class ApplicationHiredWebhookTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test 'should process the webhook, perform external calls and update received webhook object' do
    VCR.use_cassette('integration_test') do
      payload = load_test_fixture('applicant_hired.json').to_json

      post webhooks_url, params: payload, headers: { 'Content-Type': 'application/json' }

      perform_enqueued_jobs

      received_webhook = ReceivedWebhook.last

      assert_equal 'processed', received_webhook.status
      assert_nil received_webhook.error
      assert_equal(
        '{:hi_bob_employee_id=>"3397742432492716827", :hi_bob_document_id=>"15607968", :pinpoint_comment_id=>"3426547"}', received_webhook.execution_details
      )
    end
  end

  def load_test_fixture(filename)
    file_path = Rails.root.join('test', 'fixtures', 'webhooks', filename)
    JSON.parse(File.read(file_path))
  end
end
