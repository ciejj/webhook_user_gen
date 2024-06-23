module ApiClients
  module HiBob
    class Client < BaseClient
      BASE_URL = 'https://api.hibob.com/v1'.freeze
      API_USER = ENV['HI_BOB_API_USER'] || Rails.application.credentials.hi_bob_api.user
      API_PASSWORD = ENV['HI_BOB_API_PASSWORD'] || Rails.application.credentials.hi_bob_api.password
      BASIC_AUTH = "Basic #{Base64.strict_encode64("#{API_USER}:#{API_PASSWORD}")}"

      HEADERS = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Authorization' => BASIC_AUTH
      }.freeze

      class << self
        def create_new_employee(first_name:, surname:, email:, site:, start_date:)
          url = "#{BASE_URL}/people"
          body = {
            firstName: first_name,
            surname: surname,
            email: email,
            work: {
              site: site,
              startDate: start_date
            }
          }
          send_post_request(url, HEADERS, body)
        end

        def add_public_document_to_employee(employee_id:, document_name:, document_url:)
          url = "#{BASE_URL}/docs/people/#{employee_id}/shared"
          body = {
            documentName: document_name,
            documentUrl: document_url
          }
          send_post_request(url, HEADERS, body)
        end
      end
    end
  end
end
