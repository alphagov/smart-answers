require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MinimumWageCalculatorTest < ActiveSupport::TestCase
    def setup
      @calculator = MinimumWageCalculator.new
    end

    context "paid per hour" do
      should "calculate minimum wage for those aged 21 or over" do
        assert_equal @calculator.per_week_minimum_wage("21_or_over", "120"), 729.6
        assert_equal @calculator.per_week_minimum_wage("21_or_over", "20"), 121.6
      end

      should "calculate minimum wage for those aged 18 to 20" do
        assert_equal @calculator.per_week_minimum_wage("18_to_20", "120"), 597.6
        assert_equal @calculator.per_week_minimum_wage("18_to_20", "20"), 99.6
      end

      should "calculate minimum wage for those aged under 18" do
        assert_equal @calculator.per_week_minimum_wage("under_18", "120"), 441.6
        assert_equal @calculator.per_week_minimum_wage("under_18", "20"), 73.6
      end

      should "calculate minimum wage for apprentices aged under 19" do
        assert_equal @calculator.per_week_minimum_wage("under_19", "120"), 312
        assert_equal @calculator.per_week_minimum_wage("under_19", "20"), 52
      end

      should "calculate minimum wage for apprentices aged 19 or over" do
        assert_equal @calculator.per_week_minimum_wage("19_or_over", "120"), 312
        assert_equal @calculator.per_week_minimum_wage("19_or_over", "20"), 52
      end
    end

    context "paid per piece" do
      should "calculate per hour pay" do
        assert_equal @calculator.per_piece_hourly_wage("5", "25", "120"), 1.04
        assert_equal @calculator.per_piece_hourly_wage("5", "25", "20"), 6.25
      end

      should "determine whether wage is below minimum wage for those aged 21 or over" do
        assert @calculator.is_below_minimum_wage?("21_or_over", "5", "25", "120")
        refute @calculator.is_below_minimum_wage?("21_or_over", "5", "25", "20")
      end

      should "determine whether wage is below minimum wage for those aged 18 to 20" do
        assert @calculator.is_below_minimum_wage?("18_to_20", "5", "25", "120")
        refute @calculator.is_below_minimum_wage?("18_to_20", "5", "25", "20")
      end

      should "determine whether wage is below minimum wage for those aged under 18" do
        assert @calculator.is_below_minimum_wage?("under_18", "5", "25", "120")
        refute @calculator.is_below_minimum_wage?("under_18", "5", "25", "20")
      end

      should "determine whether wage is below minimum wage for apprentices aged under 19" do
        assert @calculator.is_below_minimum_wage?("under_19", "5", "25", "120")
        refute @calculator.is_below_minimum_wage?("under_19", "5", "25", "20")
      end

      should "determine whether wage is below minimum wage for apprentices aged 19 and over" do
        assert @calculator.is_below_minimum_wage?("19_or_over", "5", "25", "120")
        refute @calculator.is_below_minimum_wage?("19_or_over", "5", "25", "20")
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
        assert_equal free_adjustment - (charge * number_of_nights).round(2), charged_adjustment
        assert 0 > charged_adjustment # this should always be less than zero
      end
    end
  end
end
