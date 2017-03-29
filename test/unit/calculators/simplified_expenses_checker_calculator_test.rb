require_relative "../../test_helper"

module SmartAnswer::Calculators
  class SimplifiedExpensesCheckerCalculatorTest < ActiveSupport::TestCase
    context "list of business expenses" do
      setup do
        @calculator = SimplifiedExpensesCheckerCalculator.new
      end

      context "when artibary expenses are choosen" do
        should "be equal to the choosen expenses" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "using_home_for_business"
          assert_equal @calculator.list_of_expenses, %w(car using_home_for_business)
        end

        should "never contain more than 2 choosen expenses" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "using_home_for_business"
          assert_equal @calculator.list_of_expenses.count, 2
        end

        should "contain only contents from the selectable list of expenses" do
          @calculator.type_of_vehicle = "van"
          @calculator.business_premises_expense = "living_on_business_premises"
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
          @calculator.type_of_vehicle = "van"
          assert @calculator.vehicle?
        end

        should "be false if expense doesn't contains at least a vehicle" do
          @calculator.type_of_vehicle = "no_vehicle"
          refute @calculator.vehicle?
        end
      end

      context "#vehicle_only?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if no_expense and a vehicle selected" do
          @calculator.type_of_vehicle = "van"
          @calculator.business_premises_expense = "no_expense"
          assert @calculator.vehicle_only?
        end

        should "be false if using_home_for_business is present and doesn't contains a vehicle" do
          @calculator.type_of_vehicle = "no_vehicle"
          @calculator.business_premises_expense = "using_home_for_business"
          refute @calculator.vehicle_only?
        end

        should "be false if live_on_business_premises is present and a vehicle" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "live_on_business_premises"
          refute @calculator.vehicle_only?
        end
      end

      context "#business_premises?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if live_on_business_premises and a vehicle selected" do
          @calculator.type_of_vehicle = "van"
          @calculator.business_premises_expense = "live_on_business_premises"
          assert @calculator.business_premises?
        end

        should "be false if using_home_for_business is present and doesn't contains a vehicle" do
          @calculator.type_of_vehicle = "no_vehicle"
          @calculator.business_premises_expense = "using_home_for_business"
          refute @calculator.business_premises?
        end

        should "be false if no expense is present and a vehicle" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "no_expense"
          refute @calculator.business_premises?
        end
      end

      context "#home?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if using_home_for_business and a vehicle selected" do
          @calculator.type_of_vehicle = "van"
          @calculator.business_premises_expense = "using_home_for_business"
          assert @calculator.home?
        end

        should "be false if live_on_business_premises is present and doesn't contains a vehicle" do
          @calculator.type_of_vehicle = "no_vehicle"
          @calculator.business_premises_expense = "live_on_business_premises"
          refute @calculator.home?
        end

        should "be false if no expense is present and a vehicle" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "no_expense"
          refute @calculator.home?
        end
      end

      context "#motorcycle?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if expense contains at least a motorcycle" do
          @calculator.type_of_vehicle = "motorcycle"
          assert @calculator.motorcycle?
        end

        should "be false if expense doesn't contains at least a motorcycle" do
          @calculator.type_of_vehicle = "no_vehicle"
          refute @calculator.motorcycle?
        end
      end

      context "#car?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if expense contains at least a car" do
          @calculator.type_of_vehicle = "car"
          assert @calculator.car?
        end

        should "be false if expense doesn't contains at least a car" do
          @calculator.type_of_vehicle = "no_vehicle"
          refute @calculator.car?
        end
      end

      context "#new_car?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if expense contains a car and car_status_before_usage and new_or_used_vehicle is set to new" do
          @calculator.type_of_vehicle = "car"
          @calculator.car_status_before_usage = "new"
          @calculator.new_or_used_vehicle = "new"
          assert @calculator.new_car?
        end

        should "be true if expense contains a car and only car_status_before_usage is set to new" do
          @calculator.type_of_vehicle = "car"
          @calculator.car_status_before_usage = "new"
          assert @calculator.new_car?
        end

        should "be true if expense contains a car and only new_or_used_vehicle is set to new" do
          @calculator.type_of_vehicle = "car"
          @calculator.new_or_used_vehicle = "new"
          assert @calculator.new_car?
        end

        should "be false if expense doesn't contains a car and car_status_before_usage or new_or_used_vehicle is set to new" do
          @calculator.type_of_vehicle = "no_vehicle"
          @calculator.car_status_before_usage = "new"
          @calculator.new_or_used_vehicle = "new"
          refute @calculator.new_car?
        end
      end

      context "#used_car?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if expense contains a car and car_status_before_usage and new_or_used_vehicle is set to used" do
          @calculator.type_of_vehicle = "car"
          @calculator.car_status_before_usage = "used"
          @calculator.new_or_used_vehicle = "used"
          assert @calculator.used_car?
        end

        should "be true if expense contains a car and only car_status_before_usage is set to used" do
          @calculator.type_of_vehicle = "car"
          @calculator.car_status_before_usage = "used"
          assert @calculator.used_car?
        end

        should "be true if expense contains a car and only new_or_used_vehicle is set to used" do
          @calculator.type_of_vehicle = "car"
          @calculator.new_or_used_vehicle = "used"
          assert @calculator.used_car?
        end

        should "be false if expense doesn't contains a car and car_status_before_usage or new_or_used_vehicle is set to used" do
          @calculator.type_of_vehicle = "no_vehicle"
          @calculator.car_status_before_usage = "used"
          @calculator.new_or_used_vehicle = "used"
          refute @calculator.used_car?
        end
      end

      context "#van?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if expense contains at least a van" do
          @calculator.type_of_vehicle = "van"
          assert @calculator.van?
        end

        should "be false if expense doesn't contains at least a van" do
          @calculator.type_of_vehicle = "no_vehicle"
          refute @calculator.van?
        end
      end

      context "#working_from_home?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if it contains using_home_for_business" do
          @calculator.type_of_vehicle = "no_vehicle"
          @calculator.business_premises_expense = "using_home_for_business"
          assert @calculator.working_from_home?
        end

        should "be false if it doesn't contain using_home_for_business" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "no_expense"
          refute @calculator.working_from_home?
        end
      end

      context "#living_on_business_premises?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if it contains live_on_business_premises" do
          @calculator.business_premises_expense = "live_on_business_premises"
          assert @calculator.living_on_business_premises?
        end

        should "be false if it doesn't contain live_on_business_premises" do
          @calculator.business_premises_expense = "no_expense"
          refute @calculator.living_on_business_premises?
        end
      end

      context "#any_work_location?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if it contains using_home_for_business" do
          @calculator.business_premises_expense = "using_home_for_business"
          assert @calculator.any_work_location?
        end

        should "be true if it contains live_on_business_premises" do
          @calculator.business_premises_expense = "live_on_business_premises"
          assert @calculator.any_work_location?
        end

        should "be false if it doesn't contain using_home_for_business or live_on_business_premises" do
          @calculator.business_premises_expense = "no_expense"
          refute @calculator.any_work_location?
        end
      end

      context "#capital_allowance?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if capital_allowance is selected" do
          @calculator.selected_allowance = "capital_allowance"
          assert @calculator.capital_allowance?
        end

        should "be false if capital_allowance is not selected" do
          @calculator.selected_allowance = "simplified_expenses"
          refute @calculator.capital_allowance?
        end
      end

      context "#simplified_expenses?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if simplified_expenses is selected" do
          @calculator.selected_allowance = "simplified_expenses"
          assert @calculator.simplified_expenses?
        end

        should "be false if simplified_expenses is not selected" do
          @calculator.selected_allowance = "capital_allowance"
          refute @calculator.simplified_expenses?
        end
      end

      context "#no_allowance?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if no_allowance is selected" do
          @calculator.selected_allowance = "no"
          assert @calculator.no_allowance?
        end

        should "be false if no_allowance is not selected" do
          @calculator.selected_allowance = "capital_allowance"
          refute @calculator.no_allowance?
        end
      end

      context "#capital_allowances_estimate" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal sum of current_scheme_costs and simple_business_costs if selected_allowance isn't set to no" do
          @calculator.stubs(:current_scheme_costs).returns(10)
          @calculator.stubs(:simple_business_costs).returns(10)

          assert_equal 20, @calculator.capital_allowances_estimate
        end

        should "equal vehicle_write_off if selected_allowance is set to no" do
          @calculator.selected_allowance = "no"
          @calculator.stubs(:vehicle_write_off).returns(9)

          assert_equal 9, @calculator.capital_allowances_estimate
        end
      end

      context "#capital_allowance_claimed?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if capital allowance and expenses contains using_home_for_business" do
          @calculator.type_of_vehicle = "van"
          @calculator.business_premises_expense = "using_home_for_business"
          @calculator.selected_allowance = "capital_allowance"
          assert @calculator.capital_allowance_claimed?
        end

        should "be true if capital allowance and expenses contains live_on_business_premises" do
          @calculator.type_of_vehicle = "van"
          @calculator.business_premises_expense = "live_on_business_premises"
          @calculator.selected_allowance = "capital_allowance"
          assert @calculator.capital_allowance_claimed?
        end

        should "be false if it is not capital allowance and expenses doesn't contains using_home_for_business or living_on_business_premises" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "no_expense"
          @calculator.selected_allowance = "no"
          refute @calculator.capital_allowance_claimed?
        end

        should "be false if capital allowance and expenses doesn't contains using_home_for_business or living_on_business_premises" do
          @calculator.type_of_vehicle = "van"
          @calculator.business_premises_expense = "no_expense"
          @calculator.selected_allowance = "capital_allowance"
          refute @calculator.capital_allowance_claimed?
        end

        should "be false if it is not capital allowance and expenses  contains using_home_for_business" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "using_home_for_business"
          @calculator.selected_allowance = "no"
          refute @calculator.capital_allowance_claimed?
        end

        should "be false if it is not capital allowance and expenses  contains living_on_business_premises" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "live_on_business_premises"
          @calculator.selected_allowance = "no"
          refute @calculator.capital_allowance_claimed?
        end
      end

      context "#simplified_expenses_claimed?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if simplified expenses and expenses contains using_home_for_business" do
          @calculator.type_of_vehicle = "van"
          @calculator.business_premises_expense = "using_home_for_business"
          @calculator.selected_allowance = "simplified_expenses"
          assert @calculator.simplified_expenses_claimed?
        end

        should "be true if simplified expenses and expenses contains live_on_business_premises" do
          @calculator.type_of_vehicle = "van"
          @calculator.business_premises_expense = "live_on_business_premises"
          @calculator.selected_allowance = "simplified_expenses"
          assert @calculator.simplified_expenses_claimed?
        end

        should "be false if it is not simplified expenses and expenses doesn't contains using_home_for_business or living_on_business_premises" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "no_expense"
          @calculator.selected_allowance = "no"
          refute @calculator.simplified_expenses_claimed?
        end

        should "be false if simplified expenses and expenses doesn't contains using_home_for_business or living_on_business_premises" do
          @calculator.type_of_vehicle = "van"
          @calculator.business_premises_expense = "no_expense"
          @calculator.selected_allowance = "simplified_expenses"
          refute @calculator.simplified_expenses_claimed?
        end

        should "be false if it is not simplified expenses and expenses  contains using_home_for_business" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "using_home_for_business"
          @calculator.selected_allowance = "no"
          refute @calculator.simplified_expenses_claimed?
        end

        should "be false if it is not simplified expenses and expenses  contains living_on_business_premises" do
          @calculator.type_of_vehicle = "car"
          @calculator.business_premises_expense = "live_on_business_premises"
          @calculator.selected_allowance = "no"
          refute @calculator.simplified_expenses_claimed?
        end
      end

      context "#vehicle_is_green?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if vehicle_emission is low and car_status_before_usage is set to new" do
          @calculator.type_of_vehicle = "car"
          @calculator.car_status_before_usage = "new"
          @calculator.vehicle_emission = "low"
          assert @calculator.vehicle_is_green?
        end

        should "be true if vehicle_emission is low and new_or_used_vehicle is set to new" do
          @calculator.type_of_vehicle = "car"
          @calculator.new_or_used_vehicle = "new"
          @calculator.vehicle_emission = "low"
          assert @calculator.vehicle_is_green?
        end

        should "be false if type_of_vehicle isn't set to car" do
          @calculator.type_of_vehicle = "motorbike"
          @calculator.new_or_used_vehicle = "new"
          @calculator.vehicle_emission = "low"
          refute @calculator.vehicle_is_green?
        end

        should "be false if vehicle_emission isn't set" do
          refute @calculator.vehicle_is_green?
        end
      end

      context "#vehicle_is_dirty?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if vehicle_emission is medium" do
          @calculator.type_of_vehicle = "car"
          @calculator.vehicle_emission = "medium"
          assert @calculator.vehicle_is_dirty?
        end

        should "be false if type_of_vehicle is not a car" do
          @calculator.type_of_vehicle = "van"
          @calculator.vehicle_emission = "medium"
          refute @calculator.vehicle_is_dirty?
        end

        should "be false if vehicle_emission isn't set to medium" do
          @calculator.type_of_vehicle = "car"
          refute @calculator.vehicle_is_dirty?
        end
      end

      context "#vehicle_is_filthy?" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "be true if vehicle_emission is high" do
          @calculator.type_of_vehicle = "car"
          @calculator.vehicle_emission = "high"
          assert @calculator.vehicle_is_filthy?
        end

        should "be false if type_of_vehicle is not a car" do
          @calculator.type_of_vehicle = "van"
          @calculator.vehicle_emission = "high"
          refute @calculator.vehicle_is_filthy?
        end

        should "be false if vehicle_emission isn't set to high" do
          refute @calculator.vehicle_is_filthy?
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
          @calculator.type_of_vehicle = "car"
          @calculator.new_or_used_vehicle = "new"
          @calculator.vehicle_emission = "low"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.green_vehicle_price, 10000
        end

        should "equal nil if dirty vehicle" do
          @calculator.vehicle_emission = "medium"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.green_vehicle_price, nil
        end

        should "equal nil if filthy vehicle" do
          @calculator.vehicle_emission = "high"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.green_vehicle_price, nil
        end
      end

      context "#dirty_vehicle_price" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal nil if green vehicle" do
          @calculator.type_of_vehicle = "car"
          @calculator.new_or_used_vehicle = "new"
          @calculator.vehicle_emission = "low"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.dirty_vehicle_price, nil
        end

        should "equal nil if filthy vehicle" do
          @calculator.type_of_vehicle = "car"
          @calculator.vehicle_emission = "high"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.dirty_vehicle_price, nil
        end

        should "equal 18% of vehicle_price if vehicle is medium" do
          @calculator.type_of_vehicle = "car"
          @calculator.vehicle_emission = "medium"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.dirty_vehicle_price, 1800
        end
      end

      context "#filthy_vehicle_price" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal nil if green vehicle" do
          @calculator.type_of_vehicle = "car"
          @calculator.new_or_used_vehicle = "new"
          @calculator.vehicle_emission = "low"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.filthy_vehicle_price, nil
        end

        should "equal nil if dirty vehicle" do
          @calculator.type_of_vehicle = "car"
          @calculator.vehicle_emission = "dirty"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.filthy_vehicle_price, nil
        end

        should "equal 8% of vehicle_price if vehicle is high" do
          @calculator.type_of_vehicle = "car"
          @calculator.vehicle_emission = "high"
          @calculator.vehicle_price = 10000
          assert_equal @calculator.filthy_vehicle_price, 800
        end
      end

      context "#green_vehicle_write_off" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal business usage percentage of vehicle's green price if green vehicle" do
          @calculator.type_of_vehicle = "car"
          @calculator.new_or_used_vehicle = "new"
          @calculator.vehicle_emission = "low"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.green_vehicle_write_off, 8000
        end

        should "equal nil if dirty vehicle" do
          @calculator.vehicle_emission = "medium"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.green_vehicle_write_off, nil
        end

        should "equal nil if filthy vehicle" do
          @calculator.vehicle_emission = "high"
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
          @calculator.type_of_vehicle = "car"
          @calculator.new_or_used_vehicle = "new"
          @calculator.vehicle_emission = "low"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.dirty_vehicle_write_off, nil
        end

        should "equal nil if filthy vehicle" do
          @calculator.type_of_vehicle = "car"
          @calculator.vehicle_emission = "high"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.dirty_vehicle_write_off, nil
        end

        should "equal business usage percentage of vehicle's dirty price if vehicle is medium" do
          @calculator.type_of_vehicle = "car"
          @calculator.vehicle_emission = "medium"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.dirty_vehicle_write_off, 1440
        end
      end

      context "#filthy_vehicle_write_off" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal nil if green vehicle" do
          @calculator.type_of_vehicle = "car"
          @calculator.new_or_used_vehicle = "new"
          @calculator.vehicle_emission = "low"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.filthy_vehicle_write_off, nil
        end

        should "equal nil if dirty vehicle" do
          @calculator.type_of_vehicle = "car"
          @calculator.vehicle_emission = "medium"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.filthy_vehicle_write_off, nil
        end

        should "equal business usage percentage of vehicle's filthy price if vehicle is high" do
          @calculator.type_of_vehicle = "car"
          @calculator.vehicle_emission = "high"
          @calculator.vehicle_price = 10000
          @calculator.business_use_percent = 80
          assert_equal @calculator.filthy_vehicle_write_off, 640
        end
      end

      context "#vehicle_write_off" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal 0 if no vehicle" do
          assert_equal @calculator.vehicle_write_off, 0
        end

        should "equal green_vehicle_write_off if vehicle is green" do
          @calculator.stubs(:vehicle_is_green?).returns(true)
          @calculator.stubs(:green_vehicle_write_off).returns(10)
          assert_equal @calculator.vehicle_write_off, 10
        end

        should "equal dirty_vehicle_write_off if vehicle is dirty" do
          @calculator.stubs(:vehicle_is_dirty?).returns(true)
          @calculator.stubs(:dirty_vehicle_write_off).returns(9)
          assert_equal @calculator.vehicle_write_off, 9
        end

        should "equal filthy_vehicle_write_off if vehicle is filthy" do
          @calculator.stubs(:vehicle_is_filthy?).returns(true)
          @calculator.stubs(:filthy_vehicle_write_off).returns(8)
          assert_equal @calculator.vehicle_write_off, 8
        end
      end

      context "#simple_total" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal 0 if no car, van, motorcycle or home" do
          assert_equal @calculator.simple_total, 0
        end

        should "equal simple_vehicle_costs_car_van if only car" do
          @calculator.stubs(:car?).returns(true)
          @calculator.stubs(:simple_vehicle_costs_car_van).returns(10)
          assert_equal @calculator.simple_total, 10
        end

        should "equal simple_vehicle_costs_car_van if only van" do
          @calculator.stubs(:van?).returns(true)
          @calculator.stubs(:simple_vehicle_costs_car_van).returns(9)
          assert_equal @calculator.simple_total, 9
        end

        should "equal simple_vehicle_costs_motorcycle if only motorcycle" do
          @calculator.stubs(:motorcycle?).returns(true)
          @calculator.stubs(:simple_vehicle_costs_motorcycle).returns(9)
          assert_equal @calculator.simple_total, 9
        end

        should "equal simple_home_costs if only home" do
          @calculator.stubs(:simple_home_costs).returns(8)
          assert_equal @calculator.simple_total, 8
        end

        should "equal sum of simple_vehicle_costs_car_van and simple_home_costs if only car and home" do
          @calculator.stubs(:car?).returns(true)
          @calculator.stubs(:simple_vehicle_costs_car_van).returns(7)
          @calculator.stubs(:simple_home_costs).returns(7)
          assert_equal @calculator.simple_total, 14
        end

        should "equal sum of simple_vehicle_costs_car_van and simple_home_costs if only van and home" do
          @calculator.stubs(:van?).returns(true)
          @calculator.stubs(:simple_vehicle_costs_car_van).returns(6)
          @calculator.stubs(:simple_home_costs).returns(6)
          assert_equal @calculator.simple_total, 12
        end

        should "equal sum of simple_vehicle_costs_motorcycle and simple_home_costs if only motorcycle and home" do
          @calculator.stubs(:motorcycle?).returns(true)
          @calculator.stubs(:simple_vehicle_costs_motorcycle).returns(5)
          @calculator.stubs(:simple_home_costs).returns(5)
          assert_equal @calculator.simple_total, 10
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

      context "#current_scheme_costs" do
        setup do
          @calculator = SimplifiedExpensesCheckerCalculator.new
        end

        should "equal 0 if vehicle_costs, vehicle_write_off and home_costs aren't set" do
          assert_equal @calculator.current_scheme_costs, 0
        end

        should "equal vehicle_costs if only vehicle_costs" do
          @calculator.vehicle_costs = 1000
          assert_equal @calculator.current_scheme_costs, 1000
        end

        should "equal home_costs if only home_costs" do
          @calculator.home_costs = 999
          assert_equal @calculator.current_scheme_costs, 999
        end

        should "equal vehicle_write_off if only vehicle_write_off" do
          @calculator.stubs(:vehicle_write_off).returns(998)
          assert_equal @calculator.current_scheme_costs, 998
        end

        should "equal the sum of vehicle_costs, vehicle_write_off and home_costs if all three exist" do
          @calculator.vehicle_costs = 1000
          @calculator.home_costs = 999
          @calculator.stubs(:vehicle_write_off).returns(998)
          assert_equal @calculator.current_scheme_costs, 2997
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
