# frozen_string_literal: true

require 'test_helper'

module Webhooks
  class ApplicantsControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    def setup
      @webhook = load_test_fixture('applicant_hired.json')
    end

    test 'should consume webhook, create received_webhook record and enqueue job' do
      assert_difference 'ReceivedWebhook.count' do
        post webhooks_applicants_url, params: @webhook
      end
      assert_enqueued_jobs 1
      assert_response :ok
    end

    test 'should not consume webhook, when verification fails' do
      assert_no_difference 'ReceivedWebhook.count' do
        post webhooks_applicants_url(fail_verification: 1), params: @webhook
      end
      assert_enqueued_jobs 0
      assert_response :bad_request
    end

    private

    def load_test_fixture(filename)
      file_path = Rails.root.join('test', 'fixtures', 'webhooks', filename)
      JSON.parse(File.read(file_path))
    end
  end
end
