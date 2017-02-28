require_relative "../../test_helper"

module SmartAnswer::Calculators
  class SimplifiedExpensesCheckerCalculatorTest < ActiveSupport::TestCase
    context "list of business expenses" do
      setup do
        @calculator = SimplifiedExpensesCheckerCalculator.new
      end

      should "be empty at first" do
        assert_equal @calculator.list_of_expenses, []
      end

      context "when an artibary number of expenses are choosen" do
        should "be equal to the choosen expenses" do
          @calculator.expenses = "car,van,using_home_for_business"
          assert_equal @calculator.list_of_expenses, %w(car van using_home_for_business)
        end

        should "never contain more than 4 choosen expenses" do
          @calculator.expenses = "car,van,using_home_for_business,live_on_business_premises, unexpected"
          assert_equal @calculator.list_of_expenses.count, 4
        end

        should "contain only contents from the selectable list of expenses" do
          @calculator.expenses = "car,van,using_home_for_business,live_on_business_premises"
          @calculator.list_of_expenses.each do |expense|
            assert_includes @calculator.selectable_expenses, expense
          end
        end
      end

      context "#vehicle?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if expense contains at least a vehicle" do
          @calculator.expenses = "van,using_home_for_business"
          assert @calculator.vehicle?
        end

        should "be false if expense doesn't contains at least a vehicle" do
          @calculator.expenses = "using_home_for_business"
          refute @calculator.vehicle?
        end
      end

      context "#motorcycle?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if expense contains at least a motorcycle" do
          @calculator.expenses = "motorcycle,using_home_for_business"
          assert @calculator.motorcycle?
        end

        should "be false if expense doesn't contains at least a motorcycle" do
          @calculator.expenses = "van,using_home_for_business"
          refute @calculator.motorcycle?
        end
      end

      context "#car?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if expense contains at least a car" do
          @calculator.expenses = "car,using_home_for_business"
          assert @calculator.car?
        end

        should "be false if expense doesn't contains at least a car" do
          @calculator.expenses = "motorcycle,using_home_for_business"
          refute @calculator.car?
        end
      end

      context "#van?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if expense contains at least a van" do
          @calculator.expenses = "van,using_home_for_business"
          assert @calculator.van?
        end

        should "be false if expense doesn't contains at least a van" do
          @calculator.expenses = "car,using_home_for_business"
          refute @calculator.van?
        end
      end

      context "#working_from_home?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if it contains using_home_for_business" do
          @calculator.expenses = "car,van,using_home_for_business"
          assert @calculator.working_from_home?
        end

        should "be false if it doesn't contain using_home_for_business" do
          @calculator.expenses = "car"
          refute @calculator.working_from_home?
        end
      end

      context "#living_on_business_premises?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if it contains live_on_business_premises" do
          @calculator.expenses = "car,van,live_on_business_premises"
          assert @calculator.living_on_business_premises?
        end

        should "be false if it doesn't contain live_on_business_premises" do
          @calculator.expenses = "car"
          refute @calculator.living_on_business_premises?
        end
      end

      context "#any_work_location?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if it contains using_home_for_business" do
          @calculator.expenses = "car,van,using_home_for_business"
          assert @calculator.any_work_location?
        end

        should "be true if it contains live_on_business_premises" do
          @calculator.expenses = "car,van,live_on_business_premises"
          assert @calculator.any_work_location?
        end

        should "be false if it doesn't contain using_home_for_business or live_on_business_premises" do
          @calculator.expenses = "car"
          refute @calculator.any_work_location?
        end
      end

      context "#capital_allowance_claimed?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if capital allowance is yes and expenses contains using_home_for_business" do
          @calculator.expenses = "car,van,using_home_for_business"
          @calculator.capital_allowance = "yes"
          assert @calculator.capital_allowance_claimed?
        end

        should "be true if capital allowance is yes and expenses contains live_on_business_premises" do
          @calculator.expenses = "car,van,live_on_business_premises"
          @calculator.capital_allowance = "yes"
          assert @calculator.capital_allowance_claimed?
        end

        should "be false if capital allowance is no and expenses doesn't contains using_home_for_business or living_on_business_premises" do
          @calculator.expenses = "car"
          @calculator.capital_allowance = "no"
          refute @calculator.capital_allowance_claimed?
        end

        should "be false if capital allowance is yes and expenses doesn't contains using_home_for_business or living_on_business_premises" do
          @calculator.expenses = "car"
          @calculator.capital_allowance = "yes"
          refute @calculator.capital_allowance_claimed?
        end

        should "be false if capital allowance is no and expenses  contains using_home_for_business" do
          @calculator.expenses = "car,using_home_for_business"
          @calculator.capital_allowance = "no"
          refute @calculator.capital_allowance_claimed?
        end

        should "be false if capital allowance is no and expenses  contains living_on_business_premises" do
          @calculator.expenses = "car,living_on_business_premises"
          @calculator.capital_allowance = "no"
          refute @calculator.capital_allowance_claimed?
        end
      end

      context "#vehicle_is_green?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if no_vehicle_emission is yes" do
          @calculator.no_vehicle_emission = "yes"
          assert @calculator.vehicle_is_green?
        end

        should "be false if no_vehicle_emission is no" do
          @calculator.no_vehicle_emission = "no"
          refute @calculator.vehicle_is_green?
        end
      end

      context "#over_limit?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if vehicle_price is greater than £250,000" do
          @calculator.vehicle_price = 250001
          assert @calculator.over_limit?
        end

        should "be false if vehicle_price is less than £250,000" do
          @calculator.vehicle_price = 249999
          refute @calculator.over_limit?
        end
      end

      context "#green_vehicle_price" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal vehicle_price if green vehicle" do
          @calculator.no_vehicle_emission = "yes"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.green_vehicle_price, 10000
        end

        should "equal nil if vehicle isn't green" do
          @calculator.no_vehicle_emission = "no"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.green_vehicle_price, nil
        end
      end

      context "#dirty_vehicle_price" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal nil if green vehicle" do
          @calculator.no_vehicle_emission = "yes"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.dirty_vehicle_price, nil
        end

        should "equal 18% of vehicle_price if vehicle is dirty" do
          @calculator.no_vehicle_emission = "no"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.dirty_vehicle_price, 1800
        end
      end

      context "#green_vehicle_write_off" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal business usage percentage of vehicle's green price if green vehicle" do
          @calculator.no_vehicle_emission = "yes"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.green_vehicle_write_off, 8000
        end

        should "equal nil if vehicle isn't green" do
          @calculator.no_vehicle_emission = "no"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.green_vehicle_write_off, nil
        end
      end

      context "#dirty_vehicle_write_off" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal nil if green vehicle" do
          @calculator.no_vehicle_emission = "yes"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.dirty_vehicle_write_off, nil
        end

        should "equal business usage percentage of vehicle's dirty price if vehicle isn't green" do
          @calculator.no_vehicle_emission = "no"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.dirty_vehicle_write_off, 1440
        end
      end

      context "#simple_vehicle_costs_car_van" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal 45% of business_miles_car_van if business_miles_car_van is less than or equal to 10,000 miles" do
          @calculator.business_miles_car_van = 9999
          assert_equal @calculator.simple_vehicle_costs_car_van, 4499.55
        end

        should "equal 25% of business_miles_car_van  if business_miles_car_van is more than or equal to 10,000 miles" do
          @calculator.business_miles_car_van = 10001
          assert_equal @calculator.simple_vehicle_costs_car_van, 4500.25
        end
      end

      context "#simple_vehicle_costs_motorcycle" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal 24% of business_miles_motorcycle" do
          @calculator.business_miles_motorcycle = 100
          assert_equal @calculator.simple_vehicle_costs_motorcycle, 24
        end
      end

      context "#simple_home_costs" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal 0 if hours_worked_home is between 0 to 24" do
          @calculator.hours_worked_home = 24
          assert_equal @calculator.simple_home_costs, 0
        end

        should "equal 120 if hours_worked_home is between 25 to 50" do
          @calculator.hours_worked_home = 50
          assert_equal @calculator.simple_home_costs, 120
        end

        should "equal 216 if hours_worked_home is between 51 to 100" do
          @calculator.hours_worked_home = 51
          assert_equal @calculator.simple_home_costs, 216
        end

        should "equal 312 if hours_worked_home is greater than 100" do
          @calculator.hours_worked_home = 101
          assert_equal @calculator.simple_home_costs, 312
        end
      end

      context "#simple_business_costs" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal 0 if hours_worked_home is 0 " do
          @calculator.hours_lived_on_business_premises = 0
          assert_equal @calculator.simple_business_costs, 0
        end

        should "equal 4200 if hours_lived_on_business_premises is 1" do
          @calculator.hours_lived_on_business_premises = 1
          assert_equal @calculator.simple_business_costs, 4200
        end

        should "equal 6000 if hours_lived_on_business_premises is 2" do
          @calculator.hours_lived_on_business_premises = 2
          assert_equal @calculator.simple_business_costs, 6000
        end

        should "equal 7800 if hours_lived_on_business_premises is greater than 2" do
          @calculator.hours_lived_on_business_premises = 3
          assert_equal @calculator.simple_business_costs, 7800
        end
      end
    end
  end
end
