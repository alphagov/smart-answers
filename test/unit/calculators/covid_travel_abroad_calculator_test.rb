require_relative "../../test_helper"

module SmartAnswer::Calculators
  class CovidTravelAbroadCalculatorTest < ActiveSupport::TestCase
    setup do
      @calculator = CovidTravelAbroadCalculator.new
    end

    context "travelling_with_children=" do
      should "add a single response" do
        @calculator.travelling_with_children = "zero_to_four"

        assert_equal %w[zero_to_four], @calculator.travelling_with_children
      end

      should "add more than one response" do
        @calculator.travelling_with_children = "zero_to_four,five_to_seventeen"

        assert_equal %w[zero_to_four five_to_seventeen], @calculator.travelling_with_children
      end
    end

  end
end
