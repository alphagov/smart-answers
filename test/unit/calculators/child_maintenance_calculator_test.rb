require_relative '../../test_helper'

module SmartAnswer::Calculators
  class ChildMaintenanceCalculatorTest < ActiveSupport::TestCase
    
    context ChildMaintenanceCalculator do
      should "determine the rate scheme based on the constructor params" do
        @calculator = ChildMaintenanceCalculator.new(3)
        assert_equal :old, @calculator.calculation_scheme
        @calculator = ChildMaintenanceCalculator.new(5)
        #assert_equal :new, @calculator.calculation_scheme
        # first iteration should always use old scheme
        assert_equal :old, @calculator.calculation_scheme
      end
    end
    
    context "rate_type method" do
      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(3) 
        @calculator.net_income = 6 # old scheme at flat rate.
        assert_equal :flat, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(2) 
        @calculator.net_income = 126 # old scheme at reduced rate.
        assert_equal :reduced, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(1) 
        @calculator.net_income = 500 # old scheme at basic rate.
        assert_equal :basic, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(1) 
        @calculator.net_income = 2000 # old scheme at basic rate.
        assert_equal :basic, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(1) 
        @calculator.net_income = 2500 # old scheme at basic rate.
        assert_equal :basic, @calculator.rate_type
      end


    end
    
    # context "calculate_reduced_rate_payment method using new scheme" do
    #   should "give the reduced rate payment total" do
    #     @calculator = ChildMaintenanceCalculator.new(4)
    #     @calculator.net_income = 173.00
    #     @calculator.number_of_other_children = 1
    #     @calculator.number_of_shared_care_nights = 1
    #     assert_equal 0.37, @calculator.reduced_rate_multiplier
    #     assert_equal 0.14, @calculator.shared_care_multiplier
    #     assert_equal 29.25, @calculator.calculate_reduced_rate_payment
    #   end
    # end
    
    context "calculate_reduced_rate_payment method using old scheme" do
      should "give the correct reduced rate payment total" do
        @calculator = ChildMaintenanceCalculator.new(2)
        @calculator.net_income = 173.00
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 1
        assert_equal 0.29, @calculator.reduced_rate_multiplier
        assert_equal 0.143, @calculator.shared_care_multiplier
        assert_equal 22, @calculator.calculate_reduced_rate_payment
      end
    end
    
    # context "calculate_basic_rate_payment method using new scheme" do
    #   setup do
    #     @calculator = ChildMaintenanceCalculator.new(4)
    #     @calculator.net_income = 307.00
    #     @calculator.number_of_other_children = 2
    #     @calculator.number_of_shared_care_nights = 2
    #   end
    #   should "give the reduced rate payment total" do
    #     assert_equal 0.16, @calculator.relevant_other_child_multiplier
    #     assert_equal 0.249, @calculator.basic_rate_multiplier
    #     assert_equal 0.28, @calculator.shared_care_multiplier
    #     assert_equal 46.23, @calculator.calculate_basic_rate_payment
    #   end
    # end
    
    context "calculate_basic_rate_payment method using old scheme" do
      setup do
        @calculator = ChildMaintenanceCalculator.new(1)
        @calculator.net_income = 307.00
        @calculator.number_of_other_children = 2
        @calculator.number_of_shared_care_nights = 2
      end
      should "give the correct basic rate payment total" do
        assert_equal 0.20, @calculator.relevant_other_child_multiplier
        assert_equal 0.15, @calculator.basic_rate_multiplier
        assert_equal 0.286, @calculator.shared_care_multiplier
        assert_equal 26, @calculator.calculate_basic_rate_payment
      end
    end
    
    # context "calculate_basic_plus_rate_payment method" do
    #   setup do
    #     @calculator = ChildMaintenanceCalculator.new(4)
    #     @calculator.net_income = 2000.00
    #     @calculator.number_of_other_children = 3
    #     @calculator.number_of_shared_care_nights = 3        
    #   end
    #   should "give the basic plus rate payment total" do
    #     assert_equal 0.19, @calculator.relevant_other_child_multiplier
    #     assert_equal 0.237, @calculator.basic_rate_multiplier
    #     assert_equal 0.42, @calculator.shared_care_multiplier
    #     assert_equal 200.33, @calculator.calculate_basic_plus_rate_payment        
    #   end
    # end
    
    context "calculate_maintenance_payment method" do
      #test scenario 9
      should "calculate the child maintenance payment using the correct scheme and rate" do
        @calculator = ChildMaintenanceCalculator.new(2)
        @calculator.net_income = 500.00
        @calculator.number_of_other_children = 0
        @calculator.number_of_shared_care_nights = 4
        assert_equal 36, @calculator.calculate_maintenance_payment
      end
      #test scenario 10
      should "calculate the child maintenance payment using the correct scheme and rate" do
        @calculator = ChildMaintenanceCalculator.new(1)
        @calculator.net_income = 500.00
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 4
        assert_equal 25, @calculator.calculate_maintenance_payment
      end
      #test scenario 12
      should "calculate the child maintenance payment using the correct scheme and rate" do
        @calculator = ChildMaintenanceCalculator.new(3)
        @calculator.net_income = 500.00
        @calculator.number_of_other_children = 0
        @calculator.number_of_shared_care_nights = 1
        assert_equal 107, @calculator.calculate_maintenance_payment
      end

      #test scenario 16
      should "calculate the child maintenance payment using the correct scheme and rate - capped net income" do
        @calculator = ChildMaintenanceCalculator.new(2)
        @calculator.net_income = 2700.00
        @calculator.number_of_other_children = 0
        @calculator.number_of_shared_care_nights = 0
        assert_equal 400, @calculator.calculate_maintenance_payment
      end

      #test scenario 17 - reduced rate
      should "calculate the child maintenance payment using the correct scheme and rate - reduced rate" do
        @calculator = ChildMaintenanceCalculator.new(2)
        @calculator.net_income = 180.0
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 0
        assert_equal 28, @calculator.calculate_maintenance_payment
      end

      # test scenario 18
      should "calculate the child maintenance payment using the correct scheme and rate - reduced rate" do
        @calculator = ChildMaintenanceCalculator.new(2)
        @calculator.net_income = 180.0
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 1
        assert_equal 24, @calculator.calculate_maintenance_payment
      end

      should "calculate the child maintenance payment using the correct scheme and rate - reduced rate" do
        @calculator = ChildMaintenanceCalculator.new(2)
        @calculator.net_income = 180.0
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 2
        assert_equal 20, @calculator.calculate_maintenance_payment
      end

      should "calculate the child maintenance payment using the correct scheme and rate - reduced rate minimum of 5 pounds" do
        @calculator = ChildMaintenanceCalculator.new(2)
        @calculator.net_income = 180.0
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 4
        assert_equal 5, @calculator.calculate_maintenance_payment
      end

    end
  end
end
