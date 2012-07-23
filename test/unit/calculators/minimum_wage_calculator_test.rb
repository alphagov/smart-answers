require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MinimumWageCalculatorTest < ActiveSupport::TestCase
    def setup
      @calculator = MinimumWageCalculator.new
    end
    
    context "per hour minimum wage" do
      should "give the minimum wage for this year for a given age" do
        assert_equal 3.68, @calculator.per_hour_minimum_wage(17)
        assert_equal 4.98, @calculator.per_hour_minimum_wage(18)
        assert_equal 6.08, @calculator.per_hour_minimum_wage(21)
      end
      should "give the historical minimum wage for a given age and year" do
        assert_equal 3.64, @calculator.per_hour_minimum_wage(17, 2010)
        assert_equal 4.92, @calculator.per_hour_minimum_wage(18, 2010)
        assert_equal 5.93, @calculator.per_hour_minimum_wage(21, 2010)
      end
      should "account for the 18-22 age range before 2010" do
        assert_equal 4.83, @calculator.per_hour_minimum_wage(21, 2009)
        assert_equal 5.8, @calculator.per_hour_minimum_wage(22, 2009)
      end
    end
    
    context "accommodation adjustment" do
      setup do
        @th = SmartAnswer::Calculators::MinimumWageCalculator::ACCOMMODATION_CHARGE_THRESHOLD
      end
      should "return 0 for accommodation charged under the threshold" do
        assert_equal 0, @calculator.accommodation_adjustment("3.50", 5)
      end
      should "return the number of nights times the threshold if the accommodation is free" do
        assert_equal (@th * 4), @calculator.accommodation_adjustment("0", 4)
      end
      should "subtract the charged fee from the free fee where the accommodation costs more than the threshold" do
        charge = 10.12
        number_of_nights = 5
        free_adjustment = (@th * number_of_nights).round(2) 
        charged_adjustment = @calculator.accommodation_adjustment(charge, number_of_nights)
        assert_equal (free_adjustment - (charge * number_of_nights)).round(2), charged_adjustment
        assert 0 > charged_adjustment # this should always be less than zero
      end
    end
  end
end
