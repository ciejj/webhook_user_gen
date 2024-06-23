# frozen_string_literal: true

module Services
  module HiBob
    class CreateNewEmployee
      attr_reader :error

      def initialize(application_id:)
        @application_id = application_id
      end

      def call
        application_details = fetch_pinpoint_application_details(application_id)
        Rails.logger.info("retrieved details of application: #{application_id}")

        new_employee_params = build_new_employee_params(application_details)

        new_employee_id = create_hi_bob_employee(new_employee_params)
        Rails.logger.info("Created new employee @HiBob: #{new_employee_id}")

        cv_url = extract_cv_url(application_details)

        add_cv_to_employee(new_employee_id, cv_url)
        Rails.logger.info('CV has been added to employee @Hibob')

        add_comment_to_pinpoint_application(application_id, new_employee_id)
        Rails.logger.info("Application #{application_id} updated with employee id: #{new_employee_id}")

        true
      end

      private

      attr_reader :application_id
      attr_writer :error

      def fetch_pinpoint_application_details(application_id)
        response = ApiClients::Pinpoint::Client.fetch_application(id: application_id)
        JSON.parse(response.body, symbolize_names: true)
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
        response = ApiClients::HiBob::Client.create_new_employee(**new_employee_params)
        JSON.parse(response.body, symbolize_names: true)[:id]
      end

      def extract_cv_url(application_details)
        application_details
          .dig(:data, :attributes, :attachments)
          &.find { |attachment| attachment[:context] == 'pdf_cv' }
          &.dig(:url)
      end

      def add_cv_to_employee(employee_id, cv_url)
        ApiClients::HiBob::Client.add_public_document_to_employee(
          employee_id:,
          document_name: 'cv_pdf',
          document_url: cv_url
        )
      end

      def add_comment_to_pinpoint_application(application_id, new_employee_id)
        ApiClients::Pinpoint::Client.add_comment_to_application(
          application_id:,
          comment: "Record created with ID: #{new_employee_id}"
        )
      end
    end
  end
end
