# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateYourHolidayEntitlementTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-your-holiday-entitlement'
    @stubbed_calculator = stub(
      :formatted_full_time_part_time_days => 'stub days',
      :formatted_fraction_of_year => 'stub fraction'
    )
  end

  should "ask your employment status" do
    assert_current_node :what_is_your_employment_status?
  end

  context "full-time" do
    setup do
      add_response 'full-time'
    end

    should "ask how long you've been employed full-time" do
      assert_current_node :full_time_how_long_employed?
    end

    context "full year" do
      setup do
        add_response 'full-year'
      end

      should "ask how many days per week you're working" do
        assert_current_node :full_time_how_many_days_per_week?
      end

      should "calculate and be done when 5 days a week" do
        SmartAnswer::Calculators::HolidayEntitlement.
          expects(:new).
          with(
            :days_per_week => 5,
            :start_date => nil,
            :leaving_date => nil
          ).
          returns(@stubbed_calculator)
        @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')

        add_response '5-days'
        assert_current_node :done
        assert_state_variable :holiday_entitlement_days, 'formatted days'
        assert_phrase_list :content_sections, [:answer_ft_pt, :your_employer, :calculation_ft]
      end

      should "calculate and be done when more than 5 days a week" do
        SmartAnswer::Calculators::HolidayEntitlement.
          expects(:new).
          with(
            :days_per_week => 6,
            :start_date => nil,
            :leaving_date => nil
          ).
          returns(@stubbed_calculator)
        @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')

        add_response '6-days'
        assert_current_node :done
        assert_state_variable :holiday_entitlement_days, 'formatted days'
        assert_phrase_list :content_sections, [:answer_ft_pt_capped, :your_employer, :calculation_ft_capped]
      end
    end # full year

    context "starting this year" do
      setup do
        add_response 'starting'
      end

      should "ask when you are starting" do
        assert_current_node :full_time_starting_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-03-14"
        end

        should "ask how many days per week you work" do
          assert_current_node :full_time_how_many_days_per_week?
        end

        should "calculate and be done part year when 5 days" do
          SmartAnswer::Calculators::HolidayEntitlement.
            expects(:new).
            with(
              :days_per_week => 5,
              :start_date => "#{Date.today.year}-03-14",
              :leaving_date => nil
            ).
            returns(@stubbed_calculator)
          @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
          @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

          add_response '5-days'
          assert_current_node :done
          assert_state_variable :holiday_entitlement_days, 'formatted days'
          assert_state_variable :fraction_of_year, 'fraction of year'
          assert_state_variable :days_per_week, 5
          assert_phrase_list :content_sections, [:answer_ft_pt, :your_employer_with_rounding, :calculation_ft_partial_year]
        end

        should "calculate and be done part year when 6 days" do
          SmartAnswer::Calculators::HolidayEntitlement.
            expects(:new).
            with(
              :days_per_week => 6,
              :start_date => "#{Date.today.year}-03-14",
              :leaving_date => nil
            ).
            returns(@stubbed_calculator)
          @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
          @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

          add_response '6-days'
          assert_current_node :done
          assert_state_variable :holiday_entitlement_days, 'formatted days'
          assert_state_variable :fraction_of_year, 'fraction of year'
          assert_state_variable :days_per_week, 6
          assert_phrase_list :content_sections, [:answer_ft_pt, :your_employer_with_rounding, :calculation_ft_partial_year]
        end

        should "calculate and be done part year when 7 days" do
          SmartAnswer::Calculators::HolidayEntitlement.
            expects(:new).
            with(
              :days_per_week => 7,
              :start_date => "#{Date.today.year}-03-14",
              :leaving_date => nil
            ).
            returns(@stubbed_calculator)
          @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
          @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

          add_response '7-days'
          assert_current_node :done
          assert_state_variable :holiday_entitlement_days, 'formatted days'
          assert_state_variable :fraction_of_year, 'fraction of year'
          assert_state_variable :days_per_week, 7
          assert_phrase_list :content_sections, [:answer_ft_pt, :your_employer_with_rounding, :calculation_ft_partial_year]
        end
      end # with a start date
    end # starting this year

    context "leaving this year" do
      setup do
        add_response 'leaving'
      end

      should "ask when you are leaving" do
        assert_current_node :full_time_leaving_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-07-14"
        end

        should "ask how many days per week you work" do
          assert_current_node :full_time_how_many_days_per_week?
        end

        should "calculate and be done part year when 5 days" do
          SmartAnswer::Calculators::HolidayEntitlement.
            expects(:new).
            with(
              :days_per_week => 5,
              :start_date => nil,
              :leaving_date => "#{Date.today.year}-07-14"
            ).
            returns(@stubbed_calculator)
          @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
          @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

          add_response '5-days'
          assert_current_node :done
          assert_state_variable :holiday_entitlement_days, 'formatted days'
          assert_state_variable :fraction_of_year, 'fraction of year'
          assert_state_variable :days_per_week, 5
          assert_phrase_list :content_sections, [:answer_ft_pt, :your_employer_with_rounding, :calculation_ft_partial_year]
        end

        should "calculate and be done part year when 6 days" do
          SmartAnswer::Calculators::HolidayEntitlement.
            expects(:new).
            with(
              :days_per_week => 6,
              :start_date => nil,
              :leaving_date => "#{Date.today.year}-07-14"
            ).
            returns(@stubbed_calculator)
          @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
          @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

          add_response '6-days'
          assert_current_node :done
          assert_state_variable :holiday_entitlement_days, 'formatted days'
          assert_state_variable :fraction_of_year, 'fraction of year'
          assert_state_variable :days_per_week, 6
          assert_phrase_list :content_sections, [:answer_ft_pt, :your_employer_with_rounding, :calculation_ft_partial_year]
        end

        should "calculate and be done part year when 7 days" do
          SmartAnswer::Calculators::HolidayEntitlement.
            expects(:new).
            with(
              :days_per_week => 7,
              :start_date => nil,
              :leaving_date => "#{Date.today.year}-07-14"
            ).
            returns(@stubbed_calculator)
          @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
          @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

          add_response '7-days'
          assert_current_node :done
          assert_state_variable :holiday_entitlement_days, 'formatted days'
          assert_state_variable :fraction_of_year, 'fraction of year'
          assert_state_variable :days_per_week, 7
          assert_phrase_list :content_sections, [:answer_ft_pt, :your_employer_with_rounding, :calculation_ft_partial_year]
        end
      end # with a start date
    end # leaving this year
  end # full-time

  context "part-time" do
    setup do
      add_response 'part-time'
    end

    should "ask how long you've been employed part-time" do
      assert_current_node :part_time_how_long_employed?
    end

    context "full year" do
      setup do
        add_response 'full-year'
      end

      should "ask how many days pwe week you're working" do
        assert_current_node :part_time_how_many_days_per_week?
      end

      should "calculate and be done with a response" do
        SmartAnswer::Calculators::HolidayEntitlement.
          expects(:new).
          with(
            :days_per_week => 3,
            :start_date => nil,
            :leaving_date => nil
        ).
          returns(@stubbed_calculator)
        @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')

        add_response '3'
        assert_current_node :done
        assert_state_variable :holiday_entitlement_days, 'formatted days'
        assert_state_variable :days_per_week, 3
        assert_phrase_list :content_sections, [:answer_ft_pt, :your_employer, :calculation_pt]
      end
    end # full year

    context "starting this year" do
      setup do
        add_response 'starting'
      end

      should "ask when you are starting" do
        assert_current_node :part_time_starting_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-03-14"
        end

        should "ask how many days per week you work" do
          assert_current_node :part_time_how_many_days_per_week?
        end

        should "calculate and be done with a response" do
          SmartAnswer::Calculators::HolidayEntitlement.
            expects(:new).
            with(
              :days_per_week => 4,
              :start_date => "#{Date.today.year}-03-14",
              :leaving_date => nil
            ).
            returns(@stubbed_calculator)
          @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
          @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

          add_response '4'
          assert_current_node :done
          assert_state_variable :holiday_entitlement_days, 'formatted days'
          assert_state_variable :fraction_of_year, 'fraction of year'
          assert_state_variable :days_per_week, 4
          assert_phrase_list :content_sections, [:answer_ft_pt, :your_employer_with_rounding, :calculation_pt_partial_year]
        end
      end # with a start date
    end # starting this year

    context "leaving this year" do
      setup do
        add_response 'leaving'
      end

      should "ask when you are leaving" do
        assert_current_node :part_time_leaving_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-07-14"
        end

        should "ask how many days per week you work" do
          assert_current_node :part_time_how_many_days_per_week?
        end

        should "calculate and be done with a response" do
          SmartAnswer::Calculators::HolidayEntitlement.
            expects(:new).
            with(
              :days_per_week => 2,
              :start_date => nil,
              :leaving_date => "#{Date.today.year}-07-14"
            ).
            returns(@stubbed_calculator)
          @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
          @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

          add_response '2'
          assert_current_node :done
          assert_state_variable :holiday_entitlement_days, 'formatted days'
          assert_state_variable :fraction_of_year, 'fraction of year'
          assert_state_variable :days_per_week, 2
          assert_phrase_list :content_sections, [:answer_ft_pt, :your_employer_with_rounding, :calculation_pt_partial_year]
        end
      end # with a start date
    end # leaving this year
  end # part-time

  context "casual or irregular" do
    setup do
      add_response 'casual-or-irregular-hours'
    end

    should "ask how many hours you've worked" do
      assert_current_node :casual_or_irregular_hours?
    end

    should "be done with a response" do
      add_response '1500'
      assert_current_node :done_casual_hours
    end
  end # casual or irregular

  context "annualised hours" do
    setup do
      add_response 'annualised-hours'
    end

    should "ask how many hours you work a year" do
      assert_current_node :annualised_hours?
    end

    should "be done with a response" do
      add_response '1400'
      assert_current_node :done_annualised_hours
    end
  end # annualised hours

  context "compressed hours" do
    setup do
      add_response 'compressed-hours'
    end

    should "ask how many hours per week you work" do
      assert_current_node :compressed_hours?
    end

    should "ask how many days per weeok you work" do
      add_response '20'
      assert_current_node :compressed_hours_days?
    end

    should "be done with hours and days entered" do
      add_response '20'
      add_response '3'
      assert_current_node :done_compressed_hours
    end
  end # compressed hours

  context "shift worker" do
    setup do
      add_response 'shift-worker'
    end

    should "ask how long you're working in shifts" do
      assert_current_node :shift_worker_basis?
    end

    context "full year" do
      setup do
        add_response 'full-year'
      end

      should "ask how many hours in each shift" do
        assert_current_node :shift_worker_year_shift_length?
      end

      should "ask how many shifts per shift pattern" do
        add_response '8'
        assert_current_node :shift_worker_year_shift_count?
      end

      should "ask how many days per shift pattern" do
        add_response '8'
        add_response '4'
        assert_current_node :shift_worker_days_pattern?
      end

      should "be done when all entered" do
        add_response '8'
        add_response '4'
        add_response '7'
        assert_current_node :done_shift_worker_year
      end
    end # full year

    context "starting this year" do
      setup do
        add_response 'starting'
      end

      should "ask your start date" do
        assert_current_node :shift_worker_starting_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-02-16"
        end

        should "ask how many hours in each shift" do
          assert_current_node :shift_worker_year_shift_length?
        end

        should "ask how many shifts per shift pattern" do
          add_response '8'
          assert_current_node :shift_worker_year_shift_count?
        end

        should "ask how many days per shift pattern" do
          add_response '8'
          add_response '4'
          assert_current_node :shift_worker_days_pattern?
        end

        should "be done when all entered" do
          add_response '8'
          add_response '4'
          add_response '7'
          assert_current_node :done_shift_worker_part_year
        end
      end # with a date
    end # starting this year

    context "leaving this year" do
      setup do
        add_response 'leaving'
      end

      should "ask your leaving date" do
        assert_current_node :shift_worker_leaving_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-02-16"
        end

        should "ask how many hours in each shift" do
          assert_current_node :shift_worker_year_shift_length?
        end

        should "ask how many shifts per shift pattern" do
          add_response '8'
          assert_current_node :shift_worker_year_shift_count?
        end

        should "ask how many days per shift pattern" do
          add_response '8'
          add_response '4'
          assert_current_node :shift_worker_days_pattern?
        end

        should "be done when all entered" do
          add_response '8'
          add_response '4'
          add_response '7'
          assert_current_node :done_shift_worker_part_year
        end
      end # with a date
    end # leaving this year
  end # shift worker
end
