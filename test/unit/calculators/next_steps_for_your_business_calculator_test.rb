require_relative "../../test_helper"

module SmartAnswer::Calculators
  class NextStepsForYourBusinessCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = NextStepsForYourBusinessCalculator.new
    end

    context "#company_name" do
      setup do
        @client = mock
        CompaniesHouse::Client.stubs(:new).returns(@client)
      end

      should "return the company name" do
        @client.stubs(:company)
          .with("123456789")
          .returns({ "company_name" => "BUSINESS NAME LTD" })

        @calculator.crn = "123456789"
        assert_equal "BUSINESS NAME LTD", @calculator.company_name
      end

      should "return the nil if request not successful" do
        @client.stubs(:company)
          .with("123456789")
          .raises(CompaniesHouse::APIError, "Request error")

        @calculator.crn = "123456789"
        assert_nil @calculator.company_name
      end
    end
  end
end
