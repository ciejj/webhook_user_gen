# frozen_string_literal: true

module ApiClients
  module Pinpoint
    class Client < BaseClient
      BASE_URL = 'https://developers-test.pinpointhq.com/api/v1'
      HEADERS = {
        'Accept' => 'application/vnd.api+json',
        'X-API-KEY' => ENV['PINPOINT_API_KEY'] || Rails.application.credentials.pinpoint_api.api_key
      }.freeze

      class << self
        def fetch_application(id:)
          url = "#{BASE_URL}/applications/#{id}?extra_fields[applications]=attachments"
          response = send_get_request(url, HEADERS)

          format_response(response)
        end

        def add_comment_to_application(application_id:, comment:)
          url = "#{BASE_URL}/comments"

          body = {
            data: {
              attributes: {
                body_text: comment
              },
              relationships: {
                commentable: {
                  data: {
                    type: 'applications',
                    id: application_id.to_s
                  }
                }
              },
              type: 'comments'
            }
          }

          post_headers = HEADERS.merge({ 'Content-Type' => 'application/vnd.api+json' })

          response = send_post_request(url, post_headers, body)

          format_response(response)
        end

        private

        def format_response(response)
          parsed_body = JSON.parse(response.body, symbolize_names: true)

          OpenStruct.new(
            body: parsed_body,
            code: response.code,
            error: parsed_body.dig(:errors, 0, :detail)
          )
        end
      end
    end
  end
end
