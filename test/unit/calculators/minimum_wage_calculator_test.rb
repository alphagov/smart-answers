require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MinimumWageCalculatorTest < ActiveSupport::TestCase
    
    
    context "MinimumWageCalculator" do
      setup do
        @age = 19
        @basic_pay = 187.46
        @basic_hours = 39
        @calculator = MinimumWageCalculator.new age: @age, date: Date.parse('2010-10-01'), basic_pay: @basic_pay, basic_hours: @basic_hours
      end
      
      context "format_money" do
        should "format values to 2 decimal places with zero padding" do
          assert_equal "4.40", @calculator.format_money(4.4)
        end
      end
      
      context "minimum_wage_data_for_date" do
        should "retrieve a map of historical minimum wage data" do
          assert_equal 4.73, @calculator.minimum_wage_data_for_date[:accommodation_rate]
          assert_equal 4.51, @calculator.minimum_wage_data_for_date(Date.parse("2010-08-21"))[:accommodation_rate]
        end
      end

      context "minimum_wage_data_for_date on Sept 30th" do
        should "retrieve a map of historical minimum wage data" do
          assert_equal 4.73, @calculator.minimum_wage_data_for_date(Date.parse("2012-09-30"))[:accommodation_rate]
        end
      end
      
      context "minimum_wage_data_for_date on October 1st" do
        should "retrieve a map of historical minimum wage data" do
          assert_equal 4.82, @calculator.minimum_wage_data_for_date(Date.parse("2012-10-01"))[:accommodation_rate]
        end
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
          @calculator = MinimumWageCalculator.new age: @age, date: Date.parse('2010-10-01'), basic_pay: @basic_pay, basic_hours: 0
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
          assert !@calculator.minimum_wage_or_above?
        end
      end
      
      context "adjust for accommodation" do
        setup do
          @calculator.accommodation_adjustment(7.99, 4)
        end
        
        should "calculate the accommodation cost" do
          assert_equal -13.52, @calculator.accommodation_cost 
        end
        
        should "be included the total pay calculation" do
          assert_equal 173.94, @calculator.total_pay
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
              @historical_adjustment = ((@underpayment / 4.92) * @calculator.per_hour_minimum_wage(Date.today)).round(2)
            end
          
            should "be underpayment divided by the historical minimum hourly rate times the current minimum hourly rate" do
              assert_equal @historical_adjustment, @calculator.historical_adjustment
            end
          end
        end  
      end
      
      # Test cases from the Minimum National Wage docs.
      # see https://docs.google.com/a/digital.cabinet-office.gov.uk/spreadsheet/ccc?key=0An9oCYIY2AELdHVsckdKM0VWc2NFZ0J6MXFtdEY3MVE#gid=0
      # for various scenarios.
      #
      # Scenario 1
      context "minimum wage calculator for a 25 yr old low hourly rate" do
        setup do
          @calculator = MinimumWageCalculator.new age: 25, pay_frequency: 7, basic_pay: 168, basic_hours: 40
        end
        
        should "have a total hourly rate of 4.20" do
          assert_equal 6.08, @calculator.minimum_hourly_rate
          assert_equal 4.2, @calculator.basic_hourly_rate
          assert_equal 4.2, @calculator.total_hourly_rate
        end
        
        context "working 7 hours overtime @ 5.70" do
        
          setup do
            @calculator.overtime_hours = 7
            @calculator.overtime_hourly_rate = 5.7
          end
          
          should "calculate the total overtime pay" do
            assert_equal 29.40, @calculator.total_overtime_pay
          end
        
          should "adjust for free accommodation" do
            @calculator.accommodation_adjustment(0, 7)
            assert_equal 33.11, @calculator.accommodation_cost
            assert_equal 4.9, @calculator.total_hourly_rate
          end
          
          should "adjust for charged accommodation above threshold" do
            @calculator.accommodation_adjustment(7.5, 7)
            assert_equal -19.39, @calculator.accommodation_cost
            assert_equal 3.79, @calculator.total_hourly_rate
          end
        
          should "not adjust for charged accommodation below threshold" do
            @calculator.accommodation_adjustment(3, 7)
            assert_equal 0, @calculator.accommodation_cost
            assert_equal 4.2, @calculator.total_hourly_rate
          end

        end
        
      end
      
      # Scenario 2
      context "minimum wage calculator for a 23 yr old working 70 hours over a fortnight after 01/10/2012" do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 23, pay_frequency: 14, date: Date.parse("2012-10-01"), basic_pay: 420, basic_hours: 70)
        end
        
        should "calculate total hourly rate" do
          assert_equal 6.19, @calculator.minimum_hourly_rate
          assert_equal 6, @calculator.total_hourly_rate
        end
        
        context "working overtime" do
        
          setup do
            @calculator.overtime_hours = 2
            @calculator.overtime_hourly_rate = 8
          end
          
          should "calculate the total overtime pay" do
            assert_equal 12, @calculator.total_overtime_pay
            assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage"
          end
        
          should "adjust for free accommodation" do
            @calculator.accommodation_adjustment(0, 6)
            assert_equal 57.84, @calculator.accommodation_cost
            assert_equal 6.8, @calculator.total_hourly_rate
            assert @calculator.minimum_wage_or_above?, "should be above the minimum wage"
          end
          
          should "adjust for charged accommodation above threshold" do
            @calculator.accommodation_adjustment(7.5, 6)
            assert_equal -32.16, @calculator.accommodation_cost
            assert_equal 5.55, @calculator.total_hourly_rate
            assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage"
          end
        
          should "not adjust for charged accommodation below threshold" do
            @calculator.accommodation_adjustment(4.5, 6)
            assert_equal 0, @calculator.accommodation_cost
            assert_equal 6, @calculator.total_hourly_rate
            assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage"
          end

        end
        
      end
      
      # Scenario 3
      context "25 y/o with a low hourly rate" do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 25, date: Date.parse('2011-10-01'), pay_frequency: 7, basic_pay: 100, basic_hours: 40)
        end
        
        should "calculate total hourly rate" do
          assert_equal 6.08, @calculator.minimum_hourly_rate
          assert_equal 2.5, @calculator.basic_hourly_rate
          assert_equal 2.5, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage" 
        end
        
        should "adjust for free accommodation" do
          @calculator.accommodation_adjustment(0, 5)
          assert_equal 23.65, @calculator.accommodation_cost
          assert_equal 3.09, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage"
        end
          
        should "adjust for accommodation charged above the threshold" do
          @calculator.accommodation_adjustment(6, 5)
          assert_equal -6.35, @calculator.accommodation_cost
          assert_equal 2.34, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage"
        end
        
        should "adjust for accommodation charged below the threshold" do
          @calculator.accommodation_adjustment(4, 5)
          assert_equal 0, @calculator.accommodation_cost
          assert_equal 2.50, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage"
        end
        
      end
    
      # Scenario 4
      context "25 y/o in 2011, no accommodation, varying overtime" do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 25, date: Date.parse('2011-10-01'), pay_frequency: 7, basic_pay: 100, basic_hours: 40)
          @calculator.overtime_hours = 10
        end
        
        should "calculate total hourly rate accounting for overtime" do
          @calculator.overtime_hourly_rate = 2
          assert_equal 6.08, @calculator.minimum_hourly_rate
          assert_equal 20, @calculator.total_overtime_pay
          assert_equal 2.5, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage" 
        end
        
        should "calculate total hourly rate accounting for overtime" do
          @calculator.overtime_hourly_rate = 6
          assert_equal 6.08, @calculator.minimum_hourly_rate
          assert_equal 25, @calculator.total_overtime_pay
          assert_equal 2.5, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage" 
        end

      end
      
      # Scenario 5
      context "21 y/o in 2009, no accommodation, varying overtime" do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 21, date: Date.parse('2009-10-01'), pay_frequency: 12, basic_pay: 290, basic_hours: 60)
        end
        
        should "calculate total hourly rate accounting for overtime" do
          assert_equal 4.83, @calculator.minimum_hourly_rate
          assert_equal 4.83, @calculator.total_hourly_rate
          assert @calculator.minimum_wage_or_above?, "should be equal to the minimum wage" 
        end
        
        should "adjust for free accommodation" do
          @calculator.accommodation_adjustment(0, 5)
          assert_equal 38.65, @calculator.accommodation_cost
          assert_equal 5.48, @calculator.total_hourly_rate
          assert @calculator.minimum_wage_or_above?, "should be above the minimum wage" 
        end
        
        should "adjust for accommodation charged above the threshold" do
          @calculator.accommodation_adjustment(4.6, 5)
          assert_equal -0.77, @calculator.accommodation_cost
          assert_equal 4.82, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage" 
        end
        
        should "adjust for accommodation charged below the threshold" do
          @calculator.accommodation_adjustment(4, 5)
          assert_equal 0, @calculator.accommodation_cost
          assert_equal 4.83, @calculator.total_hourly_rate
          assert @calculator.minimum_wage_or_above?, "should be equal to the minimum wage" 
        end
        
        context "with overtime" do
          setup do
            @calculator.overtime_hours = 5
            @calculator.overtime_hourly_rate = 6
          end
          
          should "adjust for overtime" do
            assert_equal 24.15, @calculator.total_overtime_pay
            assert_equal 4.83, @calculator.total_hourly_rate
            assert @calculator.minimum_wage_or_above?, "should be equal to the minimum wage"
          end
          
          should "adjust for free accommodation as well" do
            @calculator.accommodation_adjustment(0, 5)
            assert_equal 313.95, @calculator.historical_entitlement
            assert_equal 352.80, @calculator.total_pay
            assert_equal 5.43, @calculator.total_hourly_rate
          end
          
          should "adjust for charged accommodation above the threshold" do
            @calculator.accommodation_adjustment(4.6, 5)
            assert_equal 313.95, @calculator.historical_entitlement
            assert_equal 313.38, @calculator.total_pay
            assert_equal 4.82, @calculator.total_hourly_rate
          end

          should "adjust for charged accommodation below the threshold" do
            @calculator.accommodation_adjustment(4, 5)
            assert_equal 313.95, @calculator.historical_entitlement
            assert_equal 314.15, @calculator.total_pay
            assert_equal 4.83, @calculator.total_hourly_rate
          end

        end

      end
      
      # Scenario 6
      context "25 y/o 2008-2009 with accommodation and overtime variations." do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 25, date: Date.parse('2008-10-01'), pay_frequency: 7, basic_pay: 168, basic_hours: 40)
          @calculator.overtime_hours = 7
          @calculator.overtime_hourly_rate = 5.7
        end
        
        should "calculate total hourly rate accounting for overtime" do
          assert_equal 5.73, @calculator.minimum_hourly_rate
          assert_equal 29.4, @calculator.total_overtime_pay
          assert_equal 4.2, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage" 
        end
        
        should "account for free accommodation" do
          @calculator.accommodation_adjustment 0, 7
          assert_equal 31.22, @calculator.accommodation_cost
          assert_equal 4.86, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage" 
        end
        
        should "account for charged accommodation" do
          @calculator.accommodation_adjustment 7.5, 7
          assert_equal -21.28, @calculator.accommodation_cost
          assert_equal 3.75, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage" 
        end

      end
      
      # Scenario 7
      context "18 y/o 2007-2008 with accommodation and overtime variations." do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 17, date: Date.parse('2007-10-01'), pay_frequency: 30, basic_pay: 450, basic_hours: 150)
          @calculator.overtime_hours = 8
          @calculator.overtime_hourly_rate = 4
        end
        
        should "calculate total hourly rate accounting for overtime" do
          assert_equal 3.4, @calculator.minimum_hourly_rate
          assert_equal 24, @calculator.total_overtime_pay
          assert_equal 3, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage" 
        end
        
        should "account for free accommodation" do
          @calculator.accommodation_adjustment 0, 7
          assert_equal 129.01, @calculator.accommodation_cost
          assert_equal 3.82, @calculator.total_hourly_rate
          assert @calculator.minimum_wage_or_above?, "should be above the minimum wage" 
        end
        
        should "account for charged accommodation" do
          @calculator.accommodation_adjustment 5, 7
          assert_equal -21, @calculator.accommodation_cost
          assert_equal 2.87, @calculator.total_hourly_rate
          assert_equal 537.20, @calculator.historical_entitlement
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage" 
        end

      end

      # Scenario 8
      context "25 y/o 2011-12 with high accommodation charge variations." do
        setup do
          @calculator = MinimumWageCalculator.new(
            age: 25, date: Date.parse('2012-08-21'), pay_frequency: 7, basic_pay: 350, basic_hours: 35)
          @calculator.overtime_hours = 10
          @calculator.overtime_hourly_rate = 12
        end
        
        should "calculate total hourly rate accounting for overtime" do
          assert_equal 6.08, @calculator.minimum_hourly_rate
          assert_equal 100, @calculator.total_overtime_pay
          assert_equal 10.00, @calculator.total_hourly_rate
          assert @calculator.minimum_wage_or_above?, "should be above the minimum wage" 
        end
        
        should "account for free accommodation" do
          @calculator.accommodation_adjustment 0, 7
          assert_equal 33.11, @calculator.accommodation_cost
          assert_equal 10.74, @calculator.total_hourly_rate
          assert @calculator.minimum_wage_or_above?, "should be above the minimum wage" 
        end
        
        should "account for charged accommodation" do
          @calculator.accommodation_adjustment 30, 7
          assert_equal -176.89, @calculator.accommodation_cost
          assert_equal 6.07, @calculator.total_hourly_rate
          assert !@calculator.minimum_wage_or_above?, "should be below the minimum wage" 
        end

      end
      
    end
    
    context "per hour minimum wage" do
    
      should "give the minimum wage for this year for a given age" do
        @calculator = MinimumWageCalculator.new age: 17, date: Date.today
        assert_equal 3.68, @calculator.per_hour_minimum_wage
        @calculator = MinimumWageCalculator.new age: 21, date: Date.today
        assert_equal 6.08, @calculator.per_hour_minimum_wage
      end
      should "give the historical minimum wage" do
        @calculator = MinimumWageCalculator.new age: 17, date: Date.parse('2010-10-01')
        assert_equal 3.64, @calculator.per_hour_minimum_wage
        @calculator = MinimumWageCalculator.new age: 18, date: Date.parse('2010-10-01')
        assert_equal 4.92, @calculator.per_hour_minimum_wage
      end
      should "account for the 18-22 age range before 2010" do
        @calculator = MinimumWageCalculator.new age: 21, date: Date.parse('2009-10-01')
        assert_equal 4.83, @calculator.per_hour_minimum_wage
        @calculator = MinimumWageCalculator.new age: 22, date: Date.parse('2009-10-01')
        assert_equal 5.8, @calculator.per_hour_minimum_wage
      end
    end
    
    context "accommodation adjustment" do
      setup do
        @calculator = MinimumWageCalculator.new age: 22
      end
      should "return 0 for accommodation charged under the threshold" do
        assert_equal 0, @calculator.accommodation_adjustment("3.50", 5)
      end
      should "return the number of nights times the threshold if the accommodation is free" do
        assert_equal (4.73 * 4), @calculator.accommodation_adjustment("0", 4)
      end
      should "subtract the charged fee from the free fee where the accommodation costs more than the threshold" do
        charge = 10.12
        number_of_nights = 5
        free_adjustment = (4.73 * number_of_nights).round(2) 
        charged_adjustment = @calculator.accommodation_adjustment(charge, number_of_nights)
        assert_equal (free_adjustment - (charge * number_of_nights)).round(2), charged_adjustment
        assert 0 > charged_adjustment # this should always be less than zero
      end
    end
  end
end
