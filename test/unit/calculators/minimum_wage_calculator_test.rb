require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MinimumWageCalculatorTest < ActiveSupport::TestCase
    
    
    context "instance" do
      setup do
        @basic_pay = 187.46
        @basic_hours = 39
        @calculator = MinimumWageCalculator.new age: 19, year: 2010, basic_pay: @basic_pay, basic_hours: @basic_hours
      end
      
      context "basic hourly rate" do
        should "be basic pay divided by basic hours" do
          assert_equal 4.81, @calculator.basic_hourly_rate
        end
      end 
      
      context "minimum hourly rate" do
        should "be the minimum wage per hour for the age and year" do
          assert_equal 4.92, @calculator.minimum_hourly_rate
        end
      end
      
      context "total hours" do
        should "be basic plus overtime hours" do
          @calculator.overtime_hours = 12
          assert_equal 51, @calculator.total_hours
        end
      end
      
      context "total overtime pay where overtime rate is higher than basic rate" do
        should "be basic hourly rate multiplied by overtime hours" do
          @calculator.overtime_hours = 12
          @calculator.overtime_hourly_rate = 9
          assert_equal 57.72, @calculator.total_overtime_pay
        end
      end
      
      context "total overtime pay where overtime rate is lower than basic rate" do
        should "be overtime hourly rate multiplied by overtime hours" do
          @calculator.overtime_hours = 12
          @calculator.overtime_hourly_rate = 4
          assert_equal 48, @calculator.total_overtime_pay
        end
      end
      
      context "total pay" do
        should "calculate the basic pay plus the overtime pay" do
          @calculator.overtime_hours = 11
          @calculator.overtime_hourly_rate = 4.95
          assert_equal 240.37, @calculator.total_pay
        end
      end
      
      context "historical entitlement" do
        should "be minimum wage multiplied by total hours" do
          assert_equal 191.88, @calculator.historical_entitlement
        end
      end
      
      context "above minimum wage?" do
        should "indicate if the minimum hourly rate is less than the total hourly rate" do
          assert !@calculator.above_minimum_wage?
        end
      end
      
      context "adjust for accommodation" do
        setup do
          @calculator.accommodation_adjustment(7.99, 4)
        end
        
        should "calculate the accommodation cost" do
          assert_equal -13.04, @calculator.accommodation_cost 
        end
        
        should "be included the total pay calculation" do
          assert_equal 174.42, @calculator.total_pay
        end 
      end
      
    end
    
    context "per hour minimum wage" do
    
      def setup
        @calculator = MinimumWageCalculator.new
      end
      
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
    
    context "apprentice rate" do
    
      def setup
        @calculator = MinimumWageCalculator.new
      end

      should "currently be 2.6" do
        assert_equal 2.6, @calculator.apprentice_rate
      end
      should "also accept a date" do
        assert_equal 2.6, @calculator.apprentice_rate(Date.today.year)
      end
      should "be 0 before 2010" do
        assert_equal 0, @calculator.apprentice_rate("2009")
      end
      should "be 2.5 for 2010" do
        assert_equal 2.5, @calculator.apprentice_rate("2010")
      end
    end
    
    context "accommodation adjustment" do
      setup do
        @calculator = MinimumWageCalculator.new
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
