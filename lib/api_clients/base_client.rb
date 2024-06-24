# frozen_string_literal: true

require 'uri'
require 'net/http'

module ApiClients
  class BaseClient
    class << self
      MAX_RETRIES = 3

      def send_get_request(url, headers)
        uri = URI(url)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(uri)
        headers.each { |key, value| request[key] = value }

        perform_request_with_retries(http, request)
      end

      def send_post_request(url, headers, body = nil)
        uri = URI(url)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri)
        headers.each { |key, value| request[key] = value }
        request.body = body.to_json if body

        perform_request_with_retries(http, request)
      end

      private

      def perform_request_with_retries(http, request)
        attempts = 0
        begin
          attempts += 1
          http.request(request)
        rescue Net::OpenTimeout, Net::ReadTimeout => e
          raise e unless attempts < MAX_RETRIES

          sleep(0.5 * attempts)
          retry
        end
      end
    end
  end
end
