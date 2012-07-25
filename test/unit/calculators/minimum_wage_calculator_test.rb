require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MinimumWageCalculatorTest < ActiveSupport::TestCase
    
    
    context "instance" do
      setup do
        @age = 19
        @basic_pay = 187.46
        @basic_hours = 39
        @calculator = MinimumWageCalculator.new age: @age, year: 2010, basic_pay: @basic_pay, basic_hours: @basic_hours
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
      
      context "total hourly rate" do
        should "calculate the total pay divided by total hours" do
          assert_equal 4.81, @calculator.total_hourly_rate
        end
        should "calculate the total pay divided by total hours including overtime" do
          @calculator.overtime_hours = 11
          @calculator.overtime_hourly_rate = 4.95
          assert_equal 4.81, @calculator.total_hourly_rate
        end
        should "be zero if 0 or less hours are entered" do
          @calculator = MinimumWageCalculator.new age: @age, year: 2010, basic_pay: @basic_pay, basic_hours: 0
          assert_equal 0, @calculator.total_hourly_rate
        end
      end
      
      context "total pay" do
        should "calculate the basic pay plus the overtime pay" do
          @calculator.overtime_hours = 11
          @calculator.overtime_hourly_rate = 4.95
          assert_equal 240.37, @calculator.total_pay
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
      
      context "historical entitlement" do
        setup do
          @historical_entitlement = 191.88 
        end
        should "be minimum wage for the year multiplied by total hours" do
          assert_equal @historical_entitlement, @calculator.historical_entitlement
        end
        
        context "underpayment" do  
          setup do
            @underpayment = (191.88 - @basic_pay).round(2)
          end    
          should "be the total pay minus the historical entitlement" do
            assert_equal @underpayment, @calculator.underpayment
          end
          
          context "historical_adjustment" do
            setup do
              @underpayment = (@underpayment * -1) if @underpayment < 0
              @historical_adjustment = ((@underpayment / 4.92) * @calculator.per_hour_minimum_wage(@age)).round(2)
            end
          
            should "be underpayment divided by the historical minimum hourly rate times the current minimum hourly rate" do
              assert_equal @historical_adjustment, @calculator.historical_adjustment
            end
            
            context "adjusted total underpayment" do
              should "be underpayment plus historical adjustment" do
                assert_equal (@underpayment + @historical_adjustment).round(2), @calculator.adjusted_total_underpayment 
              end
            end
          end
        end  
      end
      
      # Test case from the Minimum National Wage docs.
      #
      context "minimum wage calculator for a 25 yr old in 2008 who earned 168 over 40 hrs with 7 hrs overtime" do
        setup do
          @calculator = MinimumWageCalculator.new age: 25, year: 2008, basic_pay: 168, basic_hours: 40
          @calculator.overtime_hours = 7
          @calculator.overtime_hourly_rate = 9
        end
        
        should "have a minimum hourly rate of 5.73" do
          assert_equal 5.73, @calculator.minimum_hourly_rate
        end
        should "have a basic hourly rate of 4.20" do
          assert_equal 4.2, @calculator.basic_hourly_rate
        end
        should "have a total pay of 197.40" do
          assert_equal 197.40, @calculator.total_pay
        end
        should "have historical entitlement of 269.31" do
          assert_equal 269.31, @calculator.historical_entitlement
        end
        should "have an underpayment of 71.91" do
          assert_equal 71.91, @calculator.underpayment
        end
        should "have a historical adjustment of 76.30" do
          assert_equal 76.30, @calculator.historical_adjustment
        end
        should "have an adjusted total underpayment of 148.21" do
          assert_equal 148.21, @calculator.adjusted_total_underpayment
        end
      end
      
      context "minimum wage calculator for a 25 yr old low hourly rate" do
        setup do
          @calculator = MinimumWageCalculator.new age: 25, basic_pay: 100, basic_hours: 40
        end
        
        should "have a total hourly rate of 2.50" do
          assert_equal 6.08, @calculator.minimum_hourly_rate
          assert_equal 2.5, @calculator.basic_hourly_rate
          assert_equal 2.5, @calculator.total_hourly_rate
        end
        
        should "adjust for free accommodation" do
          @calculator.accommodation_adjustment(0, 5)
          assert_equal 23.65, @calculator.accommodation_cost
          assert_equal 3.09, @calculator.total_hourly_rate
        end
        
        should "adjust for charged accommodation above threshold" do
          @calculator.accommodation_adjustment(6, 5)
          assert_equal -6.35, @calculator.accommodation_cost
          assert_equal 2.34, @calculator.total_hourly_rate
        end
        
        should "not adjust for charged accommodation below threshold" do
          @calculator.accommodation_adjustment(4, 5)
          assert_equal 0, @calculator.accommodation_cost
          assert_equal 2.5, @calculator.total_hourly_rate
        end
        
        context "with overtime" do
          setup do
            @calculator.overtime_hours = 10
          end
          
          should "use the overtime rate for total hourly rate calculations if O/T rate is lower than basic rate" do
            @calculator.overtime_hourly_rate = 2
            assert_equal 2.4, @calculator.total_hourly_rate
          end
          should "use the basic rate for total hourly rate calculations if O/T rate is higher than basic rate" do
            @calculator.overtime_hourly_rate = 6
            assert_equal 2.5, @calculator.total_hourly_rate
          end
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
    
    context "format_money" do
      should "format values to 2 decimal places with zero padding" do
        assert_equal "4.40", @calculator.format_money(4.4)
      end
    end
  end
end
