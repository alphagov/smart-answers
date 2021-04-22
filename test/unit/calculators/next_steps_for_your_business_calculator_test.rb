require_relative "../../test_helper"

module SmartAnswer::Calculators
  class NextStepsForYourBusinessCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = NextStepsForYourBusinessCalculator.new
    end

    context "#company_exists?" do
      setup do
        @client = mock
        NextStepsForYourBusinessCalculator.stubs(:companies_house_client)
                                          .returns(@client)
      end

      should "return true if company profile is present" do
        @client.stubs(:company)
          .with("123456789")
          .returns({ "company_name" => "BUSINESS NAME LTD" })

        @calculator.crn = "123456789"
        assert @calculator.company_exists?
      end

      should "return false if company profile not found" do
        @client.stubs(:company)
          .with("123456789")
          .raises(CompaniesHouse::NotFoundError, "Not found")

        @calculator.crn = "123456789"
        assert_not @calculator.company_exists?
      end
    end

    context "#company_name" do
      setup do
        @client = mock
        NextStepsForYourBusinessCalculator.stubs(:companies_house_client)
                                          .returns(@client)
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
