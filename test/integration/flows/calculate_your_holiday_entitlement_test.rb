# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateYourHolidayEntitlementTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-your-holiday-entitlement'
    @stubbed_calculator = SmartAnswer::Calculators::HolidayEntitlement.new
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
            :leaving_date => nil,
            :leave_year_start_date => nil
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
            :leaving_date => nil,
            :leave_year_start_date => nil
          ).
          returns(@stubbed_calculator)
        @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')

        add_response '6-or-7-days'
        assert_current_node :done
        assert_state_variable :holiday_entitlement_days, 'formatted days'
        assert_phrase_list :content_sections, [:answer_fy_capped, :your_employer, :calculation_ft_capped]
      end
    end # full year

    context "starting this year" do
      setup do
        add_response 'starting'
      end

      should "ask when you are starting" do
        assert_current_node :what_is_your_starting_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-03-14"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Date.today.year}-05-02"
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
                :leaving_date => nil,
                :leave_year_start_date => "#{Date.today.year}-05-02"
              ).
              returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
            @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

            add_response '5-days'
            assert_current_node :done
            assert_state_variable :holiday_entitlement_days, 'formatted days'
            assert_state_variable :fraction_of_year, 'fraction of year'
            assert_state_variable :days_per_week, 5
            assert_phrase_list :content_sections, [:answer_ft_py, :your_employer_with_rounding, :calculation_ft_partial_year]
          end

          should "calculate and be done part year when 6 or 7 days" do
            SmartAnswer::Calculators::HolidayEntitlement.
              expects(:new).
              with(
                :days_per_week => 5,
                :start_date => "#{Date.today.year}-03-14",
                :leaving_date => nil,
                :leave_year_start_date => "#{Date.today.year}-05-02"
              ).
              returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
            @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

            add_response '6-or-7-days'
            assert_current_node :done
            assert_state_variable :holiday_entitlement_days, 'formatted days'
            assert_state_variable :fraction_of_year, 'fraction of year'
            assert_state_variable :days_per_week, 6
            assert_state_variable :days_per_week_calculated, 5
            assert_phrase_list :content_sections, [:answer_py_capped, :your_employer_with_rounding, :calculation_ft_partial_year]
          end
        end # with a leave year start date
      end # with a start date
    end # starting this year

    context "leaving this year" do
      setup do
        add_response 'leaving'
      end

      should "ask when you are leaving" do
        assert_current_node :what_is_your_leaving_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-07-14"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Date.today.year}-01-01"
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
                :leaving_date => "#{Date.today.year}-07-14",
                :leave_year_start_date => "#{Date.today.year}-01-01"
              ).
              returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
            @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

            add_response '5-days'
            assert_current_node :done
            assert_state_variable :holiday_entitlement_days, 'formatted days'
            assert_state_variable :fraction_of_year, 'fraction of year'
            assert_state_variable :days_per_week, 5
            assert_phrase_list :content_sections, [:answer_ft_py, :your_employer_with_rounding, :calculation_ft_partial_year]
          end

          should "calculate and be done part year when 6 days" do
            SmartAnswer::Calculators::HolidayEntitlement.
              expects(:new).
              with(
                :days_per_week => 5,
                :start_date => nil,
                :leaving_date => "#{Date.today.year}-07-14",
                :leave_year_start_date => "#{Date.today.year}-01-01"
              ).
              returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns('formatted days')
            @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

            add_response '6-or-7-days'
            assert_current_node :done
            assert_state_variable :holiday_entitlement_days, 'formatted days'
            assert_state_variable :fraction_of_year, 'fraction of year'
            assert_state_variable :days_per_week, 6
            assert_phrase_list :content_sections, [:answer_py_capped, :your_employer_with_rounding, :calculation_ft_partial_year]
          end
        end # with a leave year start date
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

      should "be invalid if more than 7 entered" do
        add_response '8'
        assert_current_node_is_error
        assert_current_node :part_time_how_many_days_per_week?
      end

      should "be invalid if less than 1 entered" do
        add_response '0'
        assert_current_node_is_error
        assert_current_node :part_time_how_many_days_per_week?
      end

      should "calculate and be done with a response" do
        SmartAnswer::Calculators::HolidayEntitlement.
          expects(:new).
          with(
            :days_per_week => 3,
            :start_date => nil,
            :leaving_date => nil,
            :leave_year_start_date => nil
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
        assert_current_node :what_is_your_starting_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-03-14"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Date.today.year}-08-18"
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
                :leaving_date => nil,
                :leave_year_start_date => "#{Date.today.year}-08-18"
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
        end # with a leave year start date
      end # with a start date
    end # starting this year

    context "leaving this year" do
      setup do
        add_response 'leaving'
      end

      should "ask when you are leaving" do
        assert_current_node :what_is_your_leaving_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-07-14"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Date.today.year}-12-01"
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
                :leaving_date => "#{Date.today.year}-07-14",
                :leave_year_start_date => "#{Date.today.year}-12-01"
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
        end # with a leave year start date
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

    should "be invalid if <= 0 entered" do
      add_response '0.0'
      assert_current_node_is_error
      assert_current_node :casual_or_irregular_hours?
    end

    should "calculate and be done with a response" do
      SmartAnswer::Calculators::HolidayEntitlement.
        expects(:new).
        with(:total_hours => 1500).
        returns(@stubbed_calculator)
      @stubbed_calculator.expects(:casual_irregular_entitlement).at_least_once.returns(['formatted hours', 'formatted minutes'])

      add_response '1500'
      assert_current_node :done
      assert_state_variable :total_hours, 1500.0
      assert_state_variable :holiday_entitlement_hours, 'formatted hours'
      assert_state_variable :holiday_entitlement_minutes, 'formatted minutes'
      assert_phrase_list :content_sections, [:answer_hours_minutes, :your_employer, :calculation_casual_irregular]
    end
  end # casual or irregular

  context "annualised hours" do
    setup do
      add_response 'annualised-hours'
    end

    should "ask how many hours you work a year" do
      assert_current_node :annualised_hours?
    end

    should "be invalid if <= 0 entered" do
      add_response '0.0'
      assert_current_node_is_error
      assert_current_node :annualised_hours?
    end

    should "calculate and be done with a response" do
      SmartAnswer::Calculators::HolidayEntitlement.
        expects(:new).
        with(:total_hours => 1400.5).
        returns(@stubbed_calculator)
      @stubbed_calculator.expects(:annualised_entitlement).at_least_once.returns(['formatted hours', 'formatted minutes'])
      @stubbed_calculator.expects(:formatted_annualised_hours_per_week).returns('average hours per week')

      add_response '1400.5'
      assert_current_node :done
      assert_state_variable :total_hours, 1400.5
      assert_state_variable :holiday_entitlement_hours, 'formatted hours'
      assert_state_variable :holiday_entitlement_minutes, 'formatted minutes'
      assert_state_variable :average_hours_per_week, 'average hours per week'
      assert_phrase_list :content_sections, [:answer_hours_minutes_annualised, :your_employer, :calculation_annualised]
    end
  end # annualised hours

  context "compressed hours" do
    setup do
      add_response 'compressed-hours'
    end

    should "ask how many hours per week you work" do
      assert_current_node :compressed_hours_how_many_hours_per_week?
    end

    should "be invalid if <= 0 hours per week" do
      add_response '0.0'
      assert_current_node_is_error
      assert_current_node :compressed_hours_how_many_hours_per_week?
    end

    should "be invalid if more than 168 hours per week" do
      add_response '168.1'
      assert_current_node_is_error
      assert_current_node :compressed_hours_how_many_hours_per_week?
    end

    should "ask how many days per week you work" do
      add_response '20'
      assert_current_node :compressed_hours_how_many_days_per_week?
    end

    should "be invalid with less than 1 day per week" do
      add_response '20'
      add_response '0'
      assert_current_node_is_error
      assert_current_node :compressed_hours_how_many_days_per_week?
    end

    should "be invalid with more than 7 days per week" do
      add_response '20'
      add_response '8'
      assert_current_node_is_error
      assert_current_node :compressed_hours_how_many_days_per_week?
    end

    should "calculate and be done with hours and days entered" do
      SmartAnswer::Calculators::HolidayEntitlement.
        expects(:new).
        with(:hours_per_week => 20.5, :days_per_week => 3).
        returns(@stubbed_calculator)
      @stubbed_calculator.expects(:compressed_hours_entitlement).at_least_once.returns(['formatted hours', 'formatted minutes'])
      @stubbed_calculator.expects(:compressed_hours_daily_average).at_least_once.returns(['formatted daily hours', 'formatted daily minutes'])

      add_response '20.5'
      add_response '3'
      assert_current_node :done
      assert_state_variable :hours_per_week, 20.5
      assert_state_variable :days_per_week, 3
      assert_state_variable :holiday_entitlement_hours, 'formatted hours'
      assert_state_variable :holiday_entitlement_minutes, 'formatted minutes'
      assert_state_variable :hours_daily, 'formatted daily hours'
      assert_state_variable :minutes_daily, 'formatted daily minutes'
      assert_phrase_list :content_sections, [:answer_compressed_hours, :your_employer_with_rounding, :calculation_compressed_hours]
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
        assert_current_node :shift_worker_hours_per_shift?
      end

      should "ask how many shifts per shift pattern" do
        add_response '7.5'
        assert_current_node :shift_worker_shifts_per_shift_pattern?
      end

      should "ask how many days per shift pattern" do
        add_response '7.5'
        add_response '4'
        assert_current_node :shift_worker_days_per_shift_pattern?
      end

      should "calculate and be done when all entered" do
        add_response '7.25'
        add_response '4'
        add_response '8'

        SmartAnswer::Calculators::HolidayEntitlement.
          expects(:new).
          with(
            :start_date => nil,
            :leaving_date => nil,
            :leave_year_start_date => nil,
            :hours_per_shift => 7.25,
            :shifts_per_shift_pattern => 4,
            :days_per_shift_pattern => 8
          ).
          returns(@stubbed_calculator)
        @stubbed_calculator.expects(:formatted_shifts_per_week).returns('shifts per week')
        @stubbed_calculator.expects(:formatted_shift_entitlement).returns('some shifts')

        assert_current_node :done

        assert_state_variable :hours_per_shift, '7.25'
        assert_state_variable :shifts_per_shift_pattern, 4
        assert_state_variable :days_per_shift_pattern, 8

        assert_state_variable :shifts_per_week, 'shifts per week'
        assert_state_variable :holiday_entitlement_shifts, 'some shifts'

        assert_phrase_list :content_sections, [:answer_shift_worker, :your_employer, :calculation_shift_worker]
      end
    end # full year

    context "starting this year" do
      setup do
        add_response 'starting'
      end

      should "ask your start date" do
        assert_current_node :what_is_your_starting_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-02-16"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Date.today.year}-07-01"
          end

          should "ask how many hours in each shift" do
            assert_current_node :shift_worker_hours_per_shift?
          end

          should "ask how many shifts per shift pattern" do
            add_response '8'
            assert_current_node :shift_worker_shifts_per_shift_pattern?
          end

          should "ask how many days per shift pattern" do
            add_response '8'
            add_response '4'
            assert_current_node :shift_worker_days_per_shift_pattern?
          end

          should "be done when all entered" do
            add_response '7.5'
            add_response '4'
            add_response '8'

            SmartAnswer::Calculators::HolidayEntitlement.
              expects(:new).
              with(
                :start_date => "#{Date.today.year}-02-16",
                :leaving_date => nil,
                :leave_year_start_date => "#{Date.today.year}-07-01",
                :hours_per_shift => 7.5,
                :shifts_per_shift_pattern => 4,
                :days_per_shift_pattern => 8
            ).
              returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_shifts_per_week).returns('shifts per week')
            @stubbed_calculator.expects(:formatted_shift_entitlement).returns('some shifts')
            @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

            assert_current_node :done

            assert_state_variable :hours_per_shift, '7.5'
            assert_state_variable :shifts_per_shift_pattern, 4
            assert_state_variable :days_per_shift_pattern, 8

            assert_state_variable :shifts_per_week, 'shifts per week'
            assert_state_variable :holiday_entitlement_shifts, 'some shifts'
            assert_state_variable :fraction_of_year, 'fraction of year'

            assert_phrase_list :content_sections, [:answer_shift_worker, :your_employer_with_rounding, :calculation_shift_worker_partial_year]
          end
        end # with a leave year start date
      end # with a date
    end # starting this year

    context "leaving this year" do
      setup do
        add_response 'leaving'
      end

      should "ask your leaving date" do
        assert_current_node :what_is_your_leaving_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-02-16"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Date.today.year}-08-01"
          end

          should "ask how many hours in each shift" do
            assert_current_node :shift_worker_hours_per_shift?
          end

          should "ask how many shifts per shift pattern" do
            add_response '8'
            assert_current_node :shift_worker_shifts_per_shift_pattern?
          end

          should "ask how many days per shift pattern" do
            add_response '8'
            add_response '4'
            assert_current_node :shift_worker_days_per_shift_pattern?
          end

          should "be done when all entered" do
            add_response '7'
            add_response '4'
            add_response '8'

            SmartAnswer::Calculators::HolidayEntitlement.
              expects(:new).
              with(
                :start_date => nil,
                :leaving_date => "#{Date.today.year}-02-16",
                :leave_year_start_date => "#{Date.today.year}-08-01",
                :hours_per_shift => 7,
                :shifts_per_shift_pattern => 4,
                :days_per_shift_pattern => 8
            ).
              returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_shifts_per_week).returns('shifts per week')
            @stubbed_calculator.expects(:formatted_shift_entitlement).returns('some shifts')
            @stubbed_calculator.expects(:formatted_fraction_of_year).returns('fraction of year')

            assert_current_node :done

            assert_state_variable :hours_per_shift, '7'
            assert_state_variable :shifts_per_shift_pattern, 4
            assert_state_variable :days_per_shift_pattern, 8

            assert_state_variable :shifts_per_week, 'shifts per week'
            assert_state_variable :holiday_entitlement_shifts, 'some shifts'
            assert_state_variable :fraction_of_year, 'fraction of year'

            assert_phrase_list :content_sections, [:answer_shift_worker, :your_employer_with_rounding, :calculation_shift_worker_partial_year]
          end
        end # with a leave year start date
      end # with a date
    end # leaving this year
  end # shift worker
end
