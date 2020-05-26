require_relative "../../test_helper"

module SmartAnswer::Calculators
  class BusinessCoronavirusRiskAssessmentCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = BusinessCoronavirusRiskAssessmentCalculator.new
    end

    context "#show?" do
      context "risk_assessment" do
        should "return true when criteria met" do
          @calculator.number_of_employees = "over_4"
          assert @calculator.show?(:risk_assessment)
        end

        should "return false when criteria not met" do
          @calculator.number_of_employees = "no"
          assert_not @calculator.show?(:risk_assessment)
        end
      end

      context "visitors" do
        should "return true when criteria met" do
          @calculator.visitors = "yes"
          assert @calculator.show?(:visitors)
        end

        should "return false when criteria not met" do
          @calculator.visitors = "no"
          assert_not @calculator.show?(:visitors)
        end
      end

      context "staff_meetings" do
        should "return true when criteria met" do
          @calculator.staff_meetings = "yes"
          assert @calculator.show?(:staff_meetings)
        end

        should "return false when criteria not met" do
          @calculator.staff_meetings = "no"
          assert_not @calculator.show?(:staff_meetings)
        end
      end

      context "staff_travel" do
        should "return true when criteria met" do
          @calculator.staff_travel = "yes"
          assert @calculator.show?(:staff_travel)
        end

        should "return false when criteria not met" do
          @calculator.staff_travel = "no"
          assert_not @calculator.show?(:staff_travel)
        end
      end

      context "send_or_receive_goods" do
        should "return true when criteria met" do
          @calculator.send_or_receive_goods = "yes"
          assert @calculator.show?(:send_or_receive_goods)
        end

        should "return false when criteria not met" do
          @calculator.send_or_receive_goods = "no"
          assert_not @calculator.show?(:send_or_receive_goods)
        end
      end
    end
  end
end
