require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CoronavirusEmployeeRiskAssessmentCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = CoronavirusEmployeeRiskAssessmentCalculator.new
    end

    context "#workplace_should_be_closed_to_public" do
      should "return true when criteria met" do
        @calculator.where_do_you_work = "cinema"
        @calculator.workplace_is_exception = false
        assert @calculator.workplace_should_be_closed_to_public
      end

      should "return false when workplace is exception" do
        @calculator.where_do_you_work = "cinema"
        @calculator.workplace_is_exception = true
        assert_not @calculator.workplace_should_be_closed_to_public
      end

      should "return false when workplace is 'other'" do
        @calculator.where_do_you_work = "other"
        @calculator.workplace_is_exception = false
        assert_not @calculator.workplace_should_be_closed_to_public
      end
    end
  end
end
