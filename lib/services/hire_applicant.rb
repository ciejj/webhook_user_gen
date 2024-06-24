# frozen_string_literal: true

module Services
  class HireApplicant
    attr_reader :error, :execution_details

    def initialize(application_id:)
      @application_id = application_id
      @execution_details = {}
    end

    def call
      application_details = fetch_pinpoint_application_details(application_id)
      return false unless error.blank?

      new_employee_params = build_new_employee_params(application_details)
      new_employee_id = create_hi_bob_employee(new_employee_params)
      return false unless error.blank?

      cv_url = extract_cv_url(application_details)

      if cv_url.present?
        add_cv_to_employee(new_employee_id, cv_url)
        return false unless error.blank?
      end

      add_comment_to_pinpoint_application(application_id, new_employee_id)
      return false unless error.blank?

      true
    end

    private

    attr_reader :application_id
    attr_writer :error, :execution_details

    def fetch_pinpoint_application_details(application_id)
      Rails.logger.info(">> application_id: #{application_id} | Fetching application details")

      response = ApiClients::Pinpoint::Client.fetch_application(id: application_id)
      check_response(response, 200)

      response.body
    end

    def build_new_employee_params(application_details)
      attributes = application_details.dig(:data, :attributes)

      {
        first_name: attributes[:first_name],
        surname: attributes[:last_name],
        email: attributes[:email],
        start_date: 1.day.from_now.strftime('%Y-%m-%d'),
        site: 'New York (demo)'
      }
    end

    def create_hi_bob_employee(new_employee_params)
      Rails.logger.info(">> application_id: #{application_id} | Creating employee @HiBob")
      response = ApiClients::HiBob::Client.create_new_employee(**new_employee_params)
      check_response(response, 200)

      new_employee_id = response.body[:id]
      execution_details[:hi_bob_employee_id] = new_employee_id

      new_employee_id
    end

    def extract_cv_url(application_details)
      application_details
        .dig(:data, :attributes, :attachments)
        &.find { |attachment| attachment[:context] == 'pdf_cv' }
        &.dig(:url)
    end

    def add_cv_to_employee(employee_id, cv_url)
      Rails.logger.info(">> application_id: #{application_id} | Adding CV to Employee @HiBob")

      response = ApiClients::HiBob::Client.add_public_document_to_employee(
        employee_id:,
        document_name: 'cv_pdf',
        document_url: cv_url
      )
      check_response(response, 200)

      execution_details[:hi_bob_document_id] = response.body[:id]
      response
    end

    def add_comment_to_pinpoint_application(application_id, new_employee_id)
      Rails.logger.info(">> application_id: #{application_id} | Adding comment to application @Pinpoint")

      response = ApiClients::Pinpoint::Client.add_comment_to_application(
        application_id:,
        comment: "Record created with ID: #{new_employee_id}"
      )
      check_response(response, 201)

      execution_details[:pinpoint_comment_id] = response.body.dig(:data, :id)
      response.body
    end

    def check_response(response, status_code)
      self.error = response.error if response.code != status_code
    end
  end
end
