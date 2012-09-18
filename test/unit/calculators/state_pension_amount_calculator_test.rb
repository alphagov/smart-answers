require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatePensionAmountCalculatorTest < ActiveSupport::TestCase
    context "male, born 5th April 1945, 45 qualifying years" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "male", dob: "1945-04-05", qualifying_years: "45")
      end

      should "be 107.45 for what_you_get" do
        assert_equal 107.45, @calculator.what_you_get
      end

      should "be 102.27 for you_get_future" do
        assert_equal 102.27, @calculator.you_get_future
      end

      should "be 5 automatic years" do
        @calculator.allocate_automatic_years
        assert_equal 5, @calculator.automatic_years
      end
    end

    context "female, born 7th April 1951, 39 qualifying years" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1951-04-07", qualifying_years: "45")
      end

      should "be 107.45 for what_you_get" do
        assert_equal 107.45, @calculator.what_you_get
      end

      should "be 107.45 for you_get_future" do
        assert_equal 107.45, @calculator.you_get_future
      end

      should "be 4 automatic years" do
        assert_equal 4, @calculator.allocate_automatic_years
      end
    end

    context "female, born 7th April 1951, 20 qualifying years" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1951-04-07", qualifying_years: "20")
      end

      should "be 107.45 for what_you_get" do
        assert_equal 48.84, @calculator.what_you_get
      end

      should "be 107.45 for you_get_future" do
        assert_equal 107.45, @calculator.you_get_future
      end
    end
    
    context "female, born 29th Feb 1968" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1968-02-29", qualifying_years: nil)
      end

      should "be elligible for state pension on 1 March 2034" do
        assert_equal Date.parse("2034-03-01"), @calculator.state_pension_date
      end
      
      should "be elligible for three years of credit regardless of benefits claimed" do
        assert @calculator.three_year_credit_age?
      end
      
      should "be 0 automatic years" do
        assert_equal 0, @calculator.allocate_automatic_years
      end
    end
    
    context "female born 6 Oct 1953 " do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1953-10-06", qualifying_years: nil)
      end
      
      should "qualifying_years_credit = 0" do
        assert_equal 0, @calculator.qualifying_years_credit
      end
    end 

    context "female born 6 Oct 1992 " do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1992-10-06", qualifying_years: nil)
      end
      
      should "qualifying_years_credit = 2" do
        assert_equal 2, @calculator.qualifying_years_credit
      end
    end 
    context "female born 6 Oct 1949 " do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1949-10-06", qualifying_years: nil)
      end
      
      should "allocate_automatic_years = 5" do
        assert_equal 5, @calculator.allocate_automatic_years
      end
    end 
    context "female born 6 Aug 1953 " do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1953-08-06", qualifying_years: nil)
      end
      
      should "allocate_automatic_years = 1" do
        assert_equal 1, @calculator.allocate_automatic_years
      end
    end 
  end
end
