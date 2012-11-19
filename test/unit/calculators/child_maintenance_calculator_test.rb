require_relative '../../test_helper'

module SmartAnswer::Calculators
  class ChildMaintenanceCalculatorTest < ActiveSupport::TestCase
    
    context "rate_type when benefits and no shared care" do
      should "show nil rate for low income or any income and benefits and shared care > 0" do
        @calculator = ChildMaintenanceCalculator.new(3, :old, 'no')
        @calculator.income = 4
        assert_equal :nil, @calculator.rate_type
        @calculator = ChildMaintenanceCalculator.new(3, :new, 'no')
        @calculator.income = 5
        assert_equal :nil, @calculator.rate_type
        @calculator = ChildMaintenanceCalculator.new(2, :old, 'yes')
        @calculator.number_of_shared_care_nights = 0
        assert_equal :flat, @calculator.rate_type_when_benefits
        @calculator = ChildMaintenanceCalculator.new(2, :new, 'yes')
        @calculator.number_of_shared_care_nights = 1
        assert_equal :nil, @calculator.rate_type_when_benefits
      end
    end
    
    context "rate_type method based on income" do
      # old scheme
      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(3, :old, 'no') 
        @calculator.income = 6 # old scheme at flat rate.
        assert_equal :flat, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(2, :old, 'no') 
        @calculator.income = 126 # old scheme at reduced rate.
        assert_equal :reduced, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(1, :old, 'no') 
        @calculator.income = 500 # old scheme at basic rate.
        assert_equal :basic, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(1, :old, 'no') 
        @calculator.income = 2000 # old scheme at basic rate.
        assert_equal :basic, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(1, :old, 'no') 
        @calculator.income = 2500 # old scheme at basic rate.
        assert_equal :basic, @calculator.rate_type
      end

      # new scheme
      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(3, :new, 'no') 
        @calculator.income = 6 # new scheme at flat rate.
        assert_equal :flat, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(2, :new, 'no') 
        @calculator.income = 126 # new scheme at reduced rate.
        assert_equal :reduced, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(1, :new, 'no') 
        @calculator.income = 800 # new scheme at basic rate.
        assert_equal :basic, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(1, :new, 'no') 
        @calculator.income = 2000 # new scheme at basic_plus rate.
        assert_equal :basic_plus, @calculator.rate_type
      end

      should "give the correct rate type based on the income of the payee" do
        @calculator = ChildMaintenanceCalculator.new(1, :new, 'no') 
        @calculator.income = 3500 # old scheme at basic rate.
        assert_equal :basic_plus, @calculator.rate_type
      end

    end
    
    # context "calculate_reduced_rate_payment method using new scheme" do
    #   should "give the reduced rate payment total" do
    #     @calculator = ChildMaintenanceCalculator.new(4)
    #     @calculator.income = 173.00
    #     @calculator.number_of_other_children = 1
    #     @calculator.number_of_shared_care_nights = 1
    #     assert_equal 0.37, @calculator.reduced_rate_multiplier
    #     assert_equal 0.14, @calculator.shared_care_multiplier
    #     assert_equal 29.25, @calculator.calculate_reduced_rate_payment
    #   end
    # end
    
    context "calculate_reduced_rate_payment method using old scheme" do
      should "give the correct reduced rate payment total" do
        @calculator = ChildMaintenanceCalculator.new(2, :old, 'no')
        @calculator.income = 173.00
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
    #     @calculator.income = 307.00
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
        @calculator = ChildMaintenanceCalculator.new(1, :old, 'no')
        @calculator.income = 307.00
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
    #     @calculator.income = 2000.00
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
        @calculator = ChildMaintenanceCalculator.new(2, :old, 'no')
        @calculator.income = 500.00
        @calculator.number_of_other_children = 0
        @calculator.number_of_shared_care_nights = 4
        assert_equal 36, @calculator.calculate_maintenance_payment
      end
      #test scenario 10
      should "calculate the child maintenance payment using the correct scheme and rate" do
        @calculator = ChildMaintenanceCalculator.new(1, :old, 'no')
        @calculator.income = 500.00
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 4
        assert_equal 25, @calculator.calculate_maintenance_payment
      end
      #test scenario 12
      should "calculate the child maintenance payment using the correct scheme and rate" do
        @calculator = ChildMaintenanceCalculator.new(3, :old, 'no')
        @calculator.income = 500.00
        @calculator.number_of_other_children = 0
        @calculator.number_of_shared_care_nights = 1
        assert_equal 107, @calculator.calculate_maintenance_payment
      end

      #test scenario 16
      should "calculate the child maintenance payment using the correct scheme and rate - capped net income" do
        @calculator = ChildMaintenanceCalculator.new(2, :old, 'no')
        @calculator.income = 2700.00
        @calculator.number_of_other_children = 0
        @calculator.number_of_shared_care_nights = 0
        assert_equal 400, @calculator.calculate_maintenance_payment
      end

      #test scenario 17 - reduced rate
      should "calculate the child maintenance payment using the correct scheme and rate - reduced rate" do
        @calculator = ChildMaintenanceCalculator.new(2, :old, 'no')
        @calculator.income = 180.0
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 0
        assert_equal 28, @calculator.calculate_maintenance_payment
      end

      # test scenario 18
      should "calculate the child maintenance payment using the correct scheme and rate - reduced rate" do
        @calculator = ChildMaintenanceCalculator.new(2, :old, 'no')
        @calculator.income = 180.0
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 1
        assert_equal 24, @calculator.calculate_maintenance_payment
      end

      should "calculate the child maintenance payment using the correct scheme and rate - reduced rate" do
        @calculator = ChildMaintenanceCalculator.new(2, :old, 'no')
        @calculator.income = 180.0
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 2
        assert_equal 20, @calculator.calculate_maintenance_payment
      end

      should "calculate the child maintenance payment using the correct scheme and rate - reduced rate minimum of 5 pounds" do
        @calculator = ChildMaintenanceCalculator.new(2, :old, 'no')
        @calculator.income = 180.0
        @calculator.number_of_other_children = 1
        @calculator.number_of_shared_care_nights = 4
        assert_equal 5, @calculator.calculate_maintenance_payment
      end

    end
  end
end
