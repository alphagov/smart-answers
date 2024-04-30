require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PaternityAdoptionPayCalculatorTest < ActiveSupport::TestCase
    context PaternityAdoptionPayCalculator do
      context "#paternity_deadline" do
        context "placement date is on or before 5 April 2024" do
          setup do
            @placement_date = Date.parse("5 April 2024")
          end

          should "set the paternity deadline to 55 days after the placement date" do
            match_date = Date.parse("01 March 2024")
            calculator = PaternityAdoptionPayCalculator.new(match_date)
            calculator.adoption_placement_date = @placement_date

            assert_equal Date.parse("30-05-2024"), calculator.paternity_deadline
          end
        end

        context "placement date is on or after 6 April 2024" do
          setup do
            @placement_date = Date.parse("6 April 2024")
          end

          should "set the paternity deadline to 364 days after the placement date" do
            match_date = Date.parse("01 March 2024")
            calculator = PaternityAdoptionPayCalculator.new(match_date)
            calculator.adoption_placement_date = @placement_date

            assert_equal Date.parse("05-04-2025"), calculator.paternity_deadline
          end
        end
      end

      context "#leave_must_be_taken_consecutively?" do
        should "be false when adoption placement date is 6 April 2024 (or after)" do
          calculator = PaternityAdoptionPayCalculator.new(Date.parse("1 April 2024"))
          calculator.adoption_placement_date = Date.parse("6 April 2024")

          assert_equal false, calculator.leave_must_be_taken_consecutively?
        end

        should "be true when adoption placement date is before 6 April 2024" do
          calculator = PaternityAdoptionPayCalculator.new(Date.parse("1 April 2024"))
          calculator.adoption_placement_date = Date.parse("5 April 2024")

          assert_equal true, calculator.leave_must_be_taken_consecutively?
        end
      end
    end
  end
end
