require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/calculate-your-holiday-entitlement"

class CalculateYourHolidayEntitlementTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateYourHolidayEntitlementFlow
    @stubbed_calculator = SmartAnswer::Calculators::HolidayEntitlement.new
  end

  should "ask what the basis of the calculation is" do
    assert_current_node :basis_of_calculation?
  end

  context "calculate days worked per week" do
    setup do
      add_response "days-worked-per-week"
    end

    should "ask the time period for the calculation" do
      assert_current_node :calculation_period?
    end

    context "full year" do
      setup do
        add_response "full-year"
      end

      should "ask how many days per week you're working" do
        assert_current_node :how_many_days_per_week?
      end

      should "calculate and be done when 5 days a week" do
        SmartAnswer::Calculators::HolidayEntitlement
          .expects(:new)
          .with(
            working_days_per_week: 5,
            start_date: nil,
            leaving_date: nil,
            leave_year_start_date: nil,
            ).returns(@stubbed_calculator)
        @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns("formatted days")

        add_response "5"
        assert_current_node :days_per_week_done
        assert_state_variable :holiday_entitlement_days, "formatted days"
      end

      should "calculate and be done when more than 5 days a week" do
        SmartAnswer::Calculators::HolidayEntitlement
          .expects(:new)
          .with(
            working_days_per_week: 6,
            start_date: nil,
            leaving_date: nil,
            leave_year_start_date: nil,
            ).returns(@stubbed_calculator)
        @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns("formatted days")

        add_response "6"
        assert_current_node :days_per_week_done
        assert_state_variable :holiday_entitlement_days, "formatted days"
      end
    end # full year

    context "starting this year" do
      setup do
        add_response "starting"
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
            assert_current_node :how_many_days_per_week?
          end

          context "answer 5 days" do
            setup do
              add_response "5"
            end
            should "calculate and be done part year when 5 days" do
              SmartAnswer::Calculators::HolidayEntitlement
                .expects(:new)
                .with(
                  working_days_per_week: 5,
                  start_date: Date.parse("#{Date.today.year}-03-14"),
                  leaving_date: nil,
                  leave_year_start_date: Date.parse("#{Date.today.year}-05-02"),
                  ).returns(@stubbed_calculator)
              @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns("formatted days")

              assert_current_node :days_per_week_done
              assert_state_variable :holiday_entitlement_days, "formatted days"
              assert_state_variable :working_days_per_week, 5
            end
          end

          context "answer 7 days" do
            setup do
              add_response "7"
            end
            should "calculate and be done part year when 6 or 7 days" do
              SmartAnswer::Calculators::HolidayEntitlement
                .expects(:new)
                .with(
                  working_days_per_week: 7,
                  start_date: Date.parse("#{Date.today.year}-03-14"),
                  leaving_date: nil,
                  leave_year_start_date: Date.parse("#{Date.today.year}-05-02"),
                  ).returns(@stubbed_calculator)
              @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns("formatted days")

              assert_current_node :days_per_week_done
              assert_state_variable :holiday_entitlement_days, "formatted days"
              assert_state_variable :working_days_per_week, 7
            end
          end
        end # with a leave year start date
      end # with a start date
    end # starting this year

    context "leaving this year" do
      setup do
        add_response "leaving"
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
            assert_current_node :how_many_days_per_week?
          end

          context "answer 5 days" do
            setup do
              add_response "5"
            end
            should "calculate and be done part year when 5 days" do
              SmartAnswer::Calculators::HolidayEntitlement
                .expects(:new)
                .with(
                  working_days_per_week: 5,
                  start_date: nil,
                  leaving_date: Date.parse("#{Date.today.year}-07-14"),
                  leave_year_start_date: Date.parse("#{Date.today.year}-01-01"),
                  ).returns(@stubbed_calculator)
              @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns("formatted days")

              assert_current_node :days_per_week_done
              assert_state_variable :holiday_entitlement_days, "formatted days"
              assert_state_variable :working_days_per_week, 5
            end
          end

          context "answer 6 days" do
            setup do
              add_response "6"
            end
            should "calculate and be done part year when 6 days" do
              SmartAnswer::Calculators::HolidayEntitlement
                .expects(:new)
                .with(
                  working_days_per_week: 6,
                  start_date: nil,
                  leaving_date: Date.parse("#{Date.today.year}-07-14"),
                  leave_year_start_date: Date.parse("#{Date.today.year}-01-01"),
                  ).returns(@stubbed_calculator)
              @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns("formatted days")

              assert_current_node :days_per_week_done
              assert_state_variable :holiday_entitlement_days, "formatted days"
              assert_state_variable :working_days_per_week, 6
            end
          end
        end # with a leave year start date
      end # with a start date
    end # leaving this year

    context "starting and leaving within a leave year" do
      setup do
        add_response "starting-and-leaving"
      end
      should "ask what was the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end
      context "add employment start date" do
        setup do
          add_response "#{Date.today.year}-07-14"
        end
        should "ask what date employment finished" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "add leaving_date before start_date" do
          setup do
            add_response "#{Date.today.year - 1}-10-14"
          end
          should "raise an invalid response" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end

        context "add employment end date" do
          setup do
            add_response "#{Date.today.year}-10-14"
          end
          should "ask you how many days worked per week" do
            assert_current_node :how_many_days_per_week?
          end
          should "calculate and be done part year when 5 days" do
            SmartAnswer::Calculators::HolidayEntitlement
              .expects(:new)
              .with(
                working_days_per_week: 5,
                start_date: Date.parse("#{Date.today.year}-07-14"),
                leaving_date: Date.parse("#{Date.today.year}-10-14"),
                leave_year_start_date: nil,
                ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_full_time_part_time_days).returns("formatted days")

            add_response "5"
            assert_current_node :days_per_week_done
            assert_state_variable :holiday_entitlement_days, "formatted days"
            assert_state_variable :working_days_per_week, 5
          end
        end
      end
    end
  end # calculate for days worked

  context "for hours worked per week" do
    setup do
      add_response "hours-worked-per-week"
    end
    should "ask the time period for the calculation" do
      assert_current_node :calculation_period?
    end
    context "answer full leave year" do
      setup do
        add_response "full-year"
      end
      should "ask the number of hours worked per week" do
        assert_current_node :how_many_hours_per_week?
      end
      context "answer 40 hours" do
        setup do
          add_response "40"
        end
        should "ask the number of days worked per week" do
          assert_current_node :how_many_days_per_week_for_hours?
        end
        context "answer 5 days" do
          setup do
            add_response "5"
          end
          should "calculate the holiday entitlement" do
            SmartAnswer::Calculators::HolidayEntitlement
              .expects(:new)
              .with(
                hours_per_week: 40.0,
                working_days_per_week: 5.0,
                start_date: nil,
                leaving_date: nil,
                leave_year_start_date: nil,
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:full_time_part_time_hours).returns(224.0)

            assert_current_node :hours_per_week_done
            assert_state_variable "holiday_entitlement_hours", 224
          end
        end
      end
    end
    context "answer starting part way through the leave year" do
      setup do
        add_response "starting"
      end
      should "ask for the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end
      context "answer June 1st 2019" do
        setup do
          add_response "2019-06-01"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end
        context "answer Jan 1st 2019" do
          setup do
            add_response "2019-01-01"
          end
          should "ask the number of hours worked per week" do
            assert_current_node :how_many_hours_per_week?
          end
          context "answer 40 hours" do
            setup do
              add_response "40"
            end
            should "ask the number of days worked per week" do
              assert_current_node :how_many_days_per_week_for_hours?
            end
            context "answer 5 days" do
              setup do
                add_response "5"
              end
              should "calculate the holiday entitlement" do
                SmartAnswer::Calculators::HolidayEntitlement.
                  expects(:new).
                  with(
                    hours_per_week: 40.0,
                    working_days_per_week: 5,
                    start_date: Date.parse("2019-06-01"),
                    leaving_date: nil,
                    leave_year_start_date: Date.parse("2019-01-01"),
                  ).
                  returns(@stubbed_calculator)
                @stubbed_calculator.expects(:full_time_part_time_hours).returns(132.0)

                assert_current_node :hours_per_week_done
                assert_state_variable "holiday_entitlement_hours", 132
              end
            end
          end
          context "impossible working patterns" do
            should "be invalid if answer <= 0 hours entered" do
              add_response "0"
              assert_current_node :how_many_hours_per_week?, error: true
            end

            should "be invalid if more than 168 hours entered" do
              add_response "168.5"
              assert_current_node :how_many_hours_per_week?, error: true
            end

            # Dept Test 7
            should "be invalid if 43 hours worked for 1 day (dept Test 7)" do
              add_response "43"
              add_response "1"
              assert_current_node :how_many_days_per_week_for_hours?, error: true
            end

            # Dept Test 8
            should "be invalid if 77 hours worked over 3 days (dept Test 8)" do
              add_response "77"
              add_response "3"
              assert_current_node :how_many_days_per_week_for_hours?, error: true
            end
          end
        end
      end
    end

    context "answer leaving part way through the leave year" do
      setup do
        add_response "leaving"
      end
      should "ask for the employment end date" do
        assert_current_node :what_is_your_leaving_date?
      end
      context "answer June 1st 2019" do
        setup do
          add_response "2019-06-01"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end
        context "answer Jan 1st 2019" do
          setup do
            add_response "2019-01-01"
          end
          should "ask the number of hours worked per week" do
            assert_current_node :how_many_hours_per_week?
          end
          context "answer 40 hours" do
            setup do
              add_response "40"
            end
            should "ask the number of days worked per week" do
              assert_current_node :how_many_days_per_week_for_hours?
            end
            context "answer 5 days" do
              setup do
                add_response "5"
              end
              should "calculate the holiday entitlement" do
                SmartAnswer::Calculators::HolidayEntitlement.
                  expects(:new).
                  with(
                    hours_per_week: 40,
                    working_days_per_week: 5,
                    start_date: nil,
                    leaving_date: Date.parse("2019-06-01"),
                    leave_year_start_date: Date.parse("2019-01-01"),
                  ).
                  returns(@stubbed_calculator)
                @stubbed_calculator.expects(:full_time_part_time_hours).returns(93.29)

                assert_current_node :hours_per_week_done
                assert_state_variable "holiday_entitlement_hours", 93
              end
            end
          end
          # Dept Test 16
          context "impossible working patterns" do
            should "be invalid if 63 hours for 1 day entered (dept Test 16)" do
              add_response "63"
              add_response "1"
              assert_current_node :how_many_hours_per_week?, error: true
            end
          end
        end
      end
      # Dept Test 18
      context "answer 31 September 2020" do
        setup do
          add_response "2019-06-01"
        end
        should "be an invalid date" do
          assert_current_node :what_is_your_leaving_date?, error: true
        end
      end
    end

    context "starting and leaving within a leave year" do
      setup do
        add_response "starting-and-leaving"
      end
      should "ask for the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end
      context "answer 'Jan 20th 2019'" do
        setup do
          add_response "2019-01-20"
        end
        should "ask for the employment end date" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "add leaving_date before start_date" do
          setup do
            add_response "2018-10-14"
          end
          should "raise an invalid response" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end

        context "answer 'July 18th 2019'" do
          setup do
            add_response "2019-07-18"
          end
          should "ask the number of hours worked per week" do
            assert_current_node :how_many_hours_per_week?
          end
          context "answer 40 hours" do
            setup do
              add_response "40"
            end
            should "ask the number of days worked per week" do
              assert_current_node :how_many_days_per_week_for_hours?
            end
            context "answer 5 days" do
              setup do
                add_response "5"
              end
              should "calculate the holiday entitlement" do
                SmartAnswer::Calculators::HolidayEntitlement
                  .expects(:new)
                  .with(
                    hours_per_week: 40,
                    working_days_per_week: 5,
                    start_date: Date.parse("2019-01-20"),
                    leaving_date: Date.parse("2019-07-18"),
                    leave_year_start_date: nil,
                  ).returns(@stubbed_calculator)
                @stubbed_calculator.expects(:full_time_part_time_hours).returns(110.47)

                assert_current_node :hours_per_week_done
                assert_state_variable "holiday_entitlement_hours", 110
              end
            end
          end
        end
      end
    end
  end # hours-worked-per-week

  context "for compressed hours" do
    setup do
      add_response "compressed-hours"
    end
    should "ask the time period for the calculation" do
      assert_current_node :calculation_period?
    end
    context "answer full leave year" do
      setup do
        add_response "full-year"
      end
      should "ask the number of hours worked per week" do
        assert_current_node :how_many_hours_per_week?
      end
      context "answer 40 hours" do
        setup do
          add_response "40"
        end
        should "ask the number of days worked per week" do
          assert_current_node :how_many_days_per_week_for_hours?
        end
        context "answer 5 days" do
          setup do
            add_response "5"
          end
          should "calculate the holiday entitlement" do
            assert_current_node :compressed_hours_done
            assert_state_variable "holiday_entitlement_hours", 224
            assert_state_variable "holiday_entitlement_minutes", 0
            assert_state_variable "hours_daily", 8
            assert_state_variable "minutes_daily", 0
          end
        end
      end
    end

    context "answer starting part way through the leave year" do
      setup do
        add_response "starting"
      end
      should "ask for the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end

      # Dept Test 11 - employment cannot start after leave year ends
      context "answer 1 June 2021" do
        setup do
          add_response "2021-06-01"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer 1 March 2019" do
          setup do
            add_response "2019-03-01"
          end
          should "be an invalid date" do
            assert_current_node :when_does_your_leave_year_start?, error: true
          end
        end

        # Dept Test 12 - employment cannot start after leave year ends
        context "answer 1 March 2020" do
          setup do
            add_response "2020-03-01"
          end
          should "be an invalid date" do
            assert_current_node :when_does_your_leave_year_start?, error: true
          end
        end
      end

      context "answer June 1st 2019" do
        setup do
          add_response "2019-06-01"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer Jan 1st 2019" do
          setup do
            add_response "2019-01-01"
          end
          should "ask the number of hours worked per week" do
            assert_current_node :how_many_hours_per_week?
          end

          context "impossible working patterns" do
            should "be invalid if answer <= 0 hours entered" do
              add_response "0"
              assert_current_node :how_many_hours_per_week?, error: true
            end

            should "be invalid if more than 168 hours entered" do
              add_response "168.5"
              assert_current_node :how_many_hours_per_week?, error: true
            end
          end

          context "answer 40 hours" do
            setup do
              add_response "40"
            end
            should "ask the number of days worked per week" do
              assert_current_node :how_many_days_per_week_for_hours?
            end
            context "answer 5 days" do
              setup do
                add_response "5"
              end
              should "calculate the holiday entitlement" do
                assert_current_node :compressed_hours_done
                assert_state_variable "holiday_entitlement_hours", 132
                assert_state_variable "holiday_entitlement_minutes", 0
                assert_state_variable "hours_daily", 8
                assert_state_variable "minutes_daily", 0
              end
            end
          end
        end
      end
    end

    context "answer leaving part way through the leave year" do
      setup do
        add_response "leaving"
      end
      should "ask for the employment end date" do
        assert_current_node :what_is_your_leaving_date?
      end

      context "answer June 1st 2019" do
        setup do
          add_response "2019-06-01"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end
        # Dept Test 17 - employment cannot start after leave year ends
        context "answer 1 June 2021" do
          setup do
            add_response "2021-06-01"
          end
          should "ask when the leave year started" do
            assert_current_node :when_does_your_leave_year_start?
          end

          context "answer 1 March 2019" do
            setup do
              add_response "2019-03-01"
            end
            should "be an invalid date" do
              assert_current_node :when_does_your_leave_year_start?, error: true
            end
          end

          # Dept Test 18 - employment cannot start after leave year ends
          context "answer 1 March 2020" do
            setup do
              add_response "2020-03-01"
            end
            should "be an invalid date" do
              assert_current_node :when_does_your_leave_year_start?, error: true
            end
          end
        end

        context "answer Jan 1st 2019" do
          setup do
            add_response "2019-01-01"
          end
          should "ask the number of hours worked per week" do
            assert_current_node :how_many_hours_per_week?
          end
          context "answer 40 hours" do
            setup do
              add_response "40"
            end
            should "ask the number of days worked per week" do
              assert_current_node :how_many_days_per_week_for_hours?
            end
            context "answer 5 days" do
              setup do
                add_response "5"
              end
              should "calculate the holiday entitlement" do
                assert_current_node :compressed_hours_done
                assert_state_variable "holiday_entitlement_hours", 93
                assert_state_variable "holiday_entitlement_minutes", 17
                assert_state_variable "hours_daily", 8
                assert_state_variable "minutes_daily", 0
              end
            end

            context "impossible working patterns" do
              # Dept Test 14
              should "be invalid if 73 hours for 1 day entered (dept Test 14)" do
                add_response "73"
                add_response "1"
                assert_current_node :how_many_hours_per_week?, error: true
              end

              # Dept Test 16
              should "be invalid if 40 hours for 1 day entered (dept Test 16)" do
                add_response "40"
                add_response "1"
                assert_current_node :how_many_hours_per_week?, error: true
              end
            end
          end
        end
      end
    end

    context "starting and leaving within a leave year" do
      setup do
        add_response "starting-and-leaving"
      end
      should "ask for the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end

      # Dept Test 23 - employment cannot start after leave year ends
      context "answer 1 June 2021" do
        setup do
          add_response "2021-06-01"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer 1 March 2019" do
          setup do
            add_response "2019-03-01"
          end
          should "be an invalid date" do
            assert_current_node :when_does_your_leave_year_start?, error: true
          end
        end

        # Dept Test 24 - employment cannot start after leave year ends
        context "answer 1 March 2020" do
          setup do
            add_response "2020-03-01"
          end
          should "be an invalid date" do
            assert_current_node :when_does_your_leave_year_start?, error: true
          end
        end
      end

      context "answer 'Jan 20th 2019'" do
        setup do
          add_response "2019-01-20"
        end
        should "ask for the employment end date" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "add employment end date before start_date" do
          setup do
            add_response "2018-10-14"
          end
          should "raise an invalid response" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end

        context "answer 'July 18th 2019'" do
          setup do
            add_response "2019-07-18"
          end
          should "ask the number of hours worked per week" do
            assert_current_node :how_many_hours_per_week?
          end
          context "answer 40 hours" do
            setup do
              add_response "40"
            end
            should "ask the number of days worked per week" do
              assert_current_node :how_many_days_per_week_for_hours?
            end
            context "answer 5 days" do
              setup do
                add_response "5"
              end
              should "calculate the holiday entitlement" do
                assert_current_node :compressed_hours_done
                assert_state_variable "holiday_entitlement_hours", 110
                assert_state_variable "holiday_entitlement_minutes", 28
                assert_state_variable "hours_daily", 8
                assert_state_variable "minutes_daily", 0
              end
            end
          end
        end
      end
    end
  end # compressed-hours

  context "irregular hours" do
    setup do
      add_response "irregular-hours"
    end
    should "ask the time period for the calculation" do
      assert_current_node :calculation_period?
    end

    context "answer full leave year" do
      setup do
        add_response "full-year"
      end
      should "calculate the holiday entitlement" do
        SmartAnswer::Calculators::HolidayEntitlement
          .expects(:new)
          .with(
            start_date: nil,
            leaving_date: nil,
            leave_year_start_date: nil,
          ).returns(@stubbed_calculator)
        @stubbed_calculator.expects(:formatted_full_time_part_time_weeks).returns("5.6")

        assert_state_variable "holiday_entitlement", "5.6"
        assert_current_node :irregular_and_annualised_done
      end
    end

    context "answer starting part way through the leave year" do
      setup do
        add_response "starting"
      end
      should "ask for the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end
      context "answer June 1st this year" do
        setup do
          add_response "#{Date.today.year}-06-01"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end
        context "answer Jan 1st this year" do
          setup do
            add_response "#{Date.today.year}-01-01"
          end
          should "calculate the holiday entitlement" do
            SmartAnswer::Calculators::HolidayEntitlement.
              expects(:new).
              with(
                start_date: Date.parse("#{Date.today.year}-06-01"),
                leaving_date: nil,
                leave_year_start_date: Date.parse("#{Date.today.year}-01-01"),
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_full_time_part_time_weeks).returns("3.27")

            assert_current_node :irregular_and_annualised_done
            assert_state_variable "holiday_entitlement", "3.27"
          end
        end
      end
    end

    context "answer leaving part way through the leave year" do
      setup do
        add_response "leaving"
      end
      should "ask for the employment end date" do
        assert_current_node :what_is_your_leaving_date?
      end
      context "answer June 1st this year" do
        setup do
          add_response "#{Date.today.year}-06-01"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end
        context "answer Jan 01 this year" do
          setup do
            add_response "#{Date.today.year}-01-01"
          end

          should "calculate the holiday entitlement" do
            SmartAnswer::Calculators::HolidayEntitlement.
              expects(:new).
              with(
                start_date: nil,
                leaving_date: Date.parse("#{Date.today.year}-06-01"),
                leave_year_start_date: Date.parse("#{Date.today.year}-01-01"),
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_full_time_part_time_weeks).returns("2.34")

            assert_state_variable "holiday_entitlement", "2.34"
            assert_current_node :irregular_and_annualised_done
          end
        end
      end
    end

    context "starting and leaving within a leave year" do
      setup do
        add_response "starting-and-leaving"
      end
      should "ask what was the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end
      context "answer Jan 20th this year" do
        setup do
          add_response "#{Date.today.year}-01-20"
        end
        should "ask what date employment finished" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "add employment end date before start_date" do
          setup do
            add_response "#{Date.today.year - 1}-10-14"
          end
          should "raise an invalid response" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end

        context "answer June 18th this year" do
          setup do
            add_response "#{Date.today.year}-07-18"
          end
          should "calculate the holiday entitlement" do
            SmartAnswer::Calculators::HolidayEntitlement
              .expects(:new)
              .with(
                start_date: Date.parse("#{Date.today.year}-01-20"),
                leaving_date: Date.parse("#{Date.today.year}-07-18"),
                leave_year_start_date: nil,
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_full_time_part_time_weeks).returns("2.77")

            assert_state_variable "holiday_entitlement", "2.77"
            assert_current_node :irregular_and_annualised_done
          end
        end
      end
    end
  end # irregular hours

  context "annualised hours" do
    setup do
      add_response "annualised-hours"
    end
    should "ask the time period for the calculation" do
      assert_current_node :calculation_period?
    end

    context "answer full leave year" do
      setup do
        add_response "full-year"
      end
      should "calculate the holiday entitlement" do
        SmartAnswer::Calculators::HolidayEntitlement
          .expects(:new)
          .with(
            start_date: nil,
            leaving_date: nil,
            leave_year_start_date: nil,
          ).returns(@stubbed_calculator)
        @stubbed_calculator.expects(:formatted_full_time_part_time_weeks).returns("5.6")

        assert_state_variable "holiday_entitlement", "5.6"
        assert_current_node :irregular_and_annualised_done
      end
    end

    context "answer starting part way through the leave year" do
      setup do
        add_response "starting"
      end
      should "ask for the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end
      context "answer June 1st this year" do
        setup do
          add_response "#{Date.today.year}-06-01"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end
        context "answer Jan 1st this year" do
          setup do
            add_response "#{Date.today.year}-01-01"
          end
          should "calculate the holiday entitlement" do
            SmartAnswer::Calculators::HolidayEntitlement.
              expects(:new).
              with(
                start_date: Date.parse("#{Date.today.year}-06-01"),
                leaving_date: nil,
                leave_year_start_date: Date.parse("#{Date.today.year}-01-01"),
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_full_time_part_time_weeks).returns("3.27")

            assert_current_node :irregular_and_annualised_done
            assert_state_variable "holiday_entitlement", "3.27"
          end
        end
      end
    end

    context "answer leaving part way through the leave year" do
      setup do
        add_response "leaving"
      end
      should "ask for the employment end date" do
        assert_current_node :what_is_your_leaving_date?
      end
      context "answer June 1st this year" do
        setup do
          add_response "#{Date.today.year}-06-01"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end
        context "answer Jan 01 this year" do
          setup do
            add_response "#{Date.today.year}-01-01"
          end

          should "calculate the holiday entitlement" do
            SmartAnswer::Calculators::HolidayEntitlement.
              expects(:new).
              with(
                start_date: nil,
                leaving_date: Date.parse("#{Date.today.year}-06-01"),
                leave_year_start_date: Date.parse("#{Date.today.year}-01-01"),
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_full_time_part_time_weeks).returns("2.34")

            assert_state_variable "holiday_entitlement", "2.34"
            assert_current_node :irregular_and_annualised_done
          end
        end
      end
    end

    context "starting and leaving within a leave year" do
      setup do
        add_response "starting-and-leaving"
      end
      should "ask what was the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end
      context "answer Jan 20th this year" do
        setup do
          add_response "#{Date.today.year}-01-20"
        end
        should "ask what date employment finished" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "add employment end date before start_date" do
          setup do
            add_response "#{Date.today.year - 1}-01-20"
          end
          should "raise an invalid response" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end

        context "answer June 18th this year" do
          setup do
            add_response "#{Date.today.year}-07-18"
          end
          should "calculate the holiday entitlement" do
            SmartAnswer::Calculators::HolidayEntitlement
              .expects(:new)
              .with(
                start_date: Date.parse("#{Date.today.year}-01-20"),
                leaving_date: Date.parse("#{Date.today.year}-07-18"),
                leave_year_start_date: nil,
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_full_time_part_time_weeks).returns("2.77")

            assert_state_variable "holiday_entitlement", "2.77"
            assert_current_node :irregular_and_annualised_done
          end
        end
      end
    end
  end #annualised hours

  context "shift worker" do
    setup do
      add_response "shift-worker"
    end

    should "ask how long you're working in shifts" do
      assert_current_node :shift_worker_basis?
    end

    context "answer full leave year" do
      setup do
        add_response "full-year"
      end

      should "ask how many hours in each shift" do
        assert_current_node :shift_worker_hours_per_shift?
      end
      context "answer 6 hours" do
        setup do
          add_response "6"
        end
        should "ask how many shifts per shift pattern" do
          assert_current_node :shift_worker_shifts_per_shift_pattern?
        end
        context "answer 8 shifts" do
          setup do
            add_response "8"
          end
          should "ask how many days per shift pattern" do
            assert_current_node :shift_worker_days_per_shift_pattern?
          end
          context "answer 14 days" do
            setup do
              add_response "14"
            end
            should "calculate the holiday entitlement" do
              SmartAnswer::Calculators::HolidayEntitlement
                .expects(:new)
                .with(
                  start_date: nil,
                  leaving_date: nil,
                  leave_year_start_date: nil,
                  shifts_per_shift_pattern: 8,
                  days_per_shift_pattern: 14,
                ).returns(@stubbed_calculator)
              @stubbed_calculator.expects(:shift_entitlement).returns(22.40)

              assert_current_node :shift_worker_done

              assert_state_variable :hours_per_shift, 6
              assert_state_variable :shifts_per_shift_pattern, 8
              assert_state_variable :days_per_shift_pattern, 14
              assert_state_variable :holiday_entitlement_shifts, 22.40
            end
          end
        end
      end
    end # full year

    context "answer starting this year" do
      setup do
        add_response "starting"
      end

      should "ask for the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Date.today.year}-01-01"
          end

          should "ask how many hours in each shift" do
            assert_current_node :shift_worker_hours_per_shift?
          end

          context "answer 6 hours" do
            setup do
              add_response "6"
            end

            should "ask how many shifts per shift pattern" do
              assert_current_node :shift_worker_shifts_per_shift_pattern?
            end
            context "answer 8 shifts" do
              setup do
                add_response "8"
              end

              should "ask how many days per shift pattern" do
                assert_current_node :shift_worker_days_per_shift_pattern?
              end

              context "answer 14 days" do
                setup do
                  add_response "14"
                end
                should "calculate the holiday entitlement" do
                  SmartAnswer::Calculators::HolidayEntitlement
                  .expects(:new)
                  .with(
                    start_date: Date.parse("#{Date.today.year}-06-01"),
                    leaving_date: nil,
                    leave_year_start_date: Date.parse("#{Date.today.year}-01-01"),
                    shifts_per_shift_pattern: 8,
                    days_per_shift_pattern: 14,
                  ).returns(@stubbed_calculator)
                  @stubbed_calculator.expects(:shift_entitlement).returns(13.5)

                  assert_current_node :shift_worker_done

                  assert_state_variable :hours_per_shift, 6
                  assert_state_variable :shifts_per_shift_pattern, 8
                  assert_state_variable :days_per_shift_pattern, 14
                  assert_state_variable :holiday_entitlement_shifts, 13.5
                end
              end
            end
          end
        end # with a leave year start date
      end # with a date
    end # starting this year

    context "leaving this year" do
      setup do
        add_response "leaving"
      end

      should "ask for the employment leaving date" do
        assert_current_node :what_is_your_leaving_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-06-01"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Date.today.year}-01-01"
          end

          should "ask how many hours in each shift" do
            assert_current_node :shift_worker_hours_per_shift?
          end

          context "answer 6 hours" do
            setup do
              add_response "6"
            end

            should "ask how many shifts per shift pattern" do
              assert_current_node :shift_worker_shifts_per_shift_pattern?
            end

            context "answer 8 shifts" do
              setup do
                add_response "8"
              end

              should "ask how many days per shift pattern" do
                assert_current_node :shift_worker_days_per_shift_pattern?
              end

              context "answer 14 days" do
                setup do
                  add_response "14"
                end

                should "calculate the holiday entitlement" do
                  SmartAnswer::Calculators::HolidayEntitlement
                  .expects(:new)
                  .with(
                    start_date: nil,
                    leaving_date: Date.parse("#{Date.today.year}-06-01"),
                    leave_year_start_date: Date.parse("#{Date.today.year}-01-01"),
                    shifts_per_shift_pattern: 8,
                    days_per_shift_pattern: 14,
                  ).returns(@stubbed_calculator)
                  @stubbed_calculator.expects(:shift_entitlement).returns(9.33)

                  assert_current_node :shift_worker_done

                  assert_state_variable :hours_per_shift, 6
                  assert_state_variable :shifts_per_shift_pattern, 8
                  assert_state_variable :days_per_shift_pattern, 14
                  assert_state_variable :holiday_entitlement_shifts, 9.33
                end
              end
            end
          end
        end # with a leave year start date
      end # with a date
    end # leaving this year

    context "starting and leaving this year" do
      setup do
        add_response "starting-and-leaving"
      end

      should "ask for the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-01-20"
        end

        should "ask for the employment end date" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "add employment end date before start_date" do
          setup do
            add_response "#{Date.today.year - 1}-01-20"
          end
          should "raise an invalid response" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end

        context "with a leaving date" do
          setup do
            add_response "#{Date.today.year}-07-18"
          end

          should "ask how many hours in each shift" do
            assert_current_node :shift_worker_hours_per_shift?
          end

          context "answer 6 hours" do
            setup do
              add_response "6"
            end

            should "ask how many shifts per shift pattern" do
              assert_current_node :shift_worker_shifts_per_shift_pattern?
            end

            context "answer 8 shifts" do
              setup do
                add_response "8"
              end

              should "ask how many days per shift pattern" do
                assert_current_node :shift_worker_days_per_shift_pattern?
              end

              context "answer 14 days" do
                setup do
                  add_response "14"
                end

                should "calculate the holiday entitlement" do
                  SmartAnswer::Calculators::HolidayEntitlement
                  .expects(:new)
                  .with(
                    start_date: Date.parse("#{Date.today.year}-01-20"),
                    leaving_date: Date.parse("#{Date.today.year}-07-18"),
                    leave_year_start_date: nil,
                    shifts_per_shift_pattern: 8,
                    days_per_shift_pattern: 14,
                  ).returns(@stubbed_calculator)
                  @stubbed_calculator.expects(:shift_entitlement).returns(11.05)

                  assert_current_node :shift_worker_done

                  assert_state_variable :hours_per_shift, 6
                  assert_state_variable :shifts_per_shift_pattern, 8
                  assert_state_variable :days_per_shift_pattern, 14
                  assert_state_variable :holiday_entitlement_shifts, 11.05
                end
              end
            end
          end
        end # with a leave year start date
      end # with a date
    end # leaving this year
  end # shift worker
end
