# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock # or :fakeweb if you are using fakeweb
  config.filter_sensitive_data('<PINPOINT_API_KEY>') do
    ENV['PINPOINT_API_KEY'] || Rails.application.credentials.pinpoint_api.api_key
  end
  config.filter_sensitive_data('<HI_BOB_AUTHORIZATION>') do
    username = ENV['HI_BOB_API_USER'] || Rails.application.credentials.hi_bob_api.user
    password = ENV['HI_BOB_API_PASSWORD'] || Rails.application.credentials.hi_bob_api.password

    credentials = "#{username}:#{password}"
    encoded_credentials = Base64.strict_encode64(credentials)

    "Basic #{encoded_credentials}"
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end
