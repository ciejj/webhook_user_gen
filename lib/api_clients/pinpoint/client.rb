module ApiClients
  module Pinpoint
    class Client < BaseClient
      BASE_URL = 'https://developers-test.pinpointhq.com/api/v1'.freeze
      HEADERS = {
        'Accept' => 'application/vnd.api+json',
        'X-API-KEY' => ENV['PINPOINT_API_KEY'] || Rails.application.credentials.pinpoint_api.api_key
      }.freeze

      class << self
        def fetch_application(id:)
          url = "#{BASE_URL}/applications/#{id}?extra_fields[applications]=attachments"
          send_get_request(url, HEADERS)
        end

        def add_comment_to_application(application_id:, comment:)
          url = "#{BASE_URL}/comments"

          body = {
            data: {
              relationships: {
                commentable: {
                  data: {
                    type: "applications",
                    id: application_id
                  }
                }
              },
              type: "comments",
              attributes: {
                body_text: comment
              }
            }
          }

          send_post_request(url, HEADERS, body)
        end
      end
    end
  end
end
