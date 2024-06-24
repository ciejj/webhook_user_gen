# frozen_string_literal: true

require 'test_helper'

class HireApplicantTest < Minitest::Test
  def test_that_applicant_is_hired_successfully
    # to recreate this cassette we need an application id, for which employee has not been yet created @ HiBob
    VCR.use_cassette('hire_applicant_successful', record: :none) do
      hire_applicant_service = Services::HireApplicant.new(application_id: 8_863_807)
      response = hire_applicant_service.call
      assert_equal true, response
      assert_equal({
                     hi_bob_employee_id: '3397352260643062621',
                     hi_bob_document_id: '15587714',
                     pinpoint_comment_id: '3422365'
                   }, hire_applicant_service.execution_details)
    end
  end

  def test_that_application_is_not_found
    # to recreate this cassette we need an incorrect application_id
    VCR.use_cassette('hire_applicant_incorrect_application_id', record: :none) do
      hire_applicant_service = Services::HireApplicant.new(application_id: 1_234_567_890)
      response = hire_applicant_service.call
      assert_equal false, response
      assert_equal 'Specified Record Not Found', hire_applicant_service.error
      assert_equal({}, hire_applicant_service.execution_details)
    end
  end

  def test_that_employee_is_alrady_hired
    VCR.use_cassette('hire_applicant_that_is_already_employed', record: :none) do
      # to recreate this cassette we need an application id, for which employee has been already created @ HiBob
      hire_applicant_service = Services::HireApplicant.new(application_id: 8_863_801)
      response = hire_applicant_service.call
      assert_equal false, response
      assert_equal 'validations.email.alreadyexists', hire_applicant_service.error
      assert_equal({:hi_bob_employee_id=>nil}, hire_applicant_service.execution_details)

    end
  end

  def test_that_adding_comment_to_application_fails
    VCR.use_cassette('hire_applicant_application_update_fails', record: :none) do
      # to recreate this cassette we need to pass empty body when sending comment to Pinpoint
      # this way we can mimic situation, when application was somehow removed in meantime
      hire_applicant_service = Services::HireApplicant.new(application_id: 8_863_807)
      response = hire_applicant_service.call
      assert_equal false, response
      assert_equal 'Commentable must exist', hire_applicant_service.error
      assert_equal({:hi_bob_employee_id=>"3397352260643062621", :hi_bob_document_id=>"15587714", :pinpoint_comment_id=>nil}, hire_applicant_service.execution_details)
    end
  end
end
