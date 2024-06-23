require 'test_helper'

class CreateNewEmployeeTest < Minitest::Test
  def test_that_new_employee_is_succesfully_created
    VCR.use_cassette('create_employee_successful') do
      create_new_employee_service = Services::HiBob::CreateNewEmployee.new(application_id: 8863817)
      response = create_new_employee_service.call
      assert_equal true, response, "Expected `Services::HiBob::CreateNewEmployee.execute` to return `true`, but got `#{response}`"
    end
  end
end
