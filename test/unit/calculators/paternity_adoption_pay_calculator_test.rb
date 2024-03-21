require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PaternityAdoptionPayCalculatorTest < ActiveSupport::TestCase
    context PaternityAdoptionPayCalculator do
      context "#paternity_deadline" do
        should "give paternity deadlne based on placement date" do
          match_date = Date.parse("01 July 2020")
          placement_date = Date.parse("01 August 2020")
          calculator = PaternityAdoptionPayCalculator.new(match_date)
          calculator.adoption_placement_date = placement_date
          assert_equal "25-09-2020", calculator.paternity_deadline
        end
      end
    end
  end
end
