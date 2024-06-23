# frozen_string_literal: true

require 'uri'
require 'net/http'

module ApiClients
  class BaseClient
    class << self
      def send_get_request(url, headers)
        uri = URI(url)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(uri)
        headers.each { |key, value| request[key] = value }

        http.request(request)
      end

      def send_post_request(url, headers, body = nil)
        uri = URI(url)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri)
        headers.each { |key, value| request[key] = value }
        request.body = body.to_json if body

        http.request(request)
      end
    end
  end
end
