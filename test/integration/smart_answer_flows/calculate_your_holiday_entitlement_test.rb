require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/calculate-your-holiday-entitlement"

class CalculateYourHolidayEntitlementTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    travel_to Time.zone.local(2020)
    setup_for_testing_flow SmartAnswer::CalculateYourHolidayEntitlementFlow
  end

  teardown do
    travel_back
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
        add_response "5"
        assert_current_node :days_per_week_done
        assert_equal "28", current_state.calculator.formatted_full_time_part_time_days
      end

      should "calculate and be done when more than 5 days a week" do
        add_response "6"
        assert_current_node :days_per_week_done
        assert_equal "28", current_state.calculator.formatted_full_time_part_time_days
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
          add_response "#{Time.zone.today.year}-03-14"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Time.zone.today.year}-03-02"
          end

          should "ask how many days per week you work" do
            assert_current_node :how_many_days_per_week?
          end

          context "answer 5 days" do
            setup do
              add_response "5"
            end

            should "calculate and be done part year when 5 days" do
              assert_current_node :days_per_week_done
              assert_equal "28", current_state.calculator.formatted_full_time_part_time_days
              assert_equal 5, current_state.calculator.working_days_per_week
            end
          end

          context "answer 7 days" do
            setup do
              add_response "7"
            end

            should "calculate and be done part year when 6 or 7 days" do
              assert_current_node :days_per_week_done
              assert_equal "28", current_state.calculator.formatted_full_time_part_time_days
              assert_equal 7, current_state.calculator.working_days_per_week
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
          add_response "#{Time.zone.today.year}-07-14"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Time.zone.today.year}-01-01"
          end

          should "ask how many days per week you work" do
            assert_current_node :how_many_days_per_week?
          end

          context "answer 5 days" do
            setup do
              add_response "5"
            end

            should "calculate and be done part year when 5 days" do
              assert_current_node :days_per_week_done
              assert_equal "15", current_state.calculator.formatted_full_time_part_time_days
              assert_equal 5, current_state.calculator.working_days_per_week
            end
          end

          context "answer 6 days" do
            setup do
              add_response "6"
            end

            should "calculate and be done part year when 6 days" do
              assert_current_node :days_per_week_done
              assert_equal "15", current_state.calculator.formatted_full_time_part_time_days
              assert_equal 6, current_state.calculator.working_days_per_week
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
          add_response "#{Time.zone.today.year}-07-14"
        end

        should "ask what date employment finished" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "add leaving_date before start_date" do
          setup do
            add_response "#{Time.zone.today.year - 1}-10-14"
          end

          should "raise an invalid response" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end

        context "add employment end date" do
          setup do
            add_response "#{Time.zone.today.year}-10-14"
          end

          should "ask you how many days worked per week" do
            assert_current_node :how_many_days_per_week?
          end

          should "calculate and be done part year when 5 days" do
            add_response "5"
            assert_current_node :days_per_week_done
            assert_equal "7.2", current_state.calculator.formatted_full_time_part_time_days
            assert_equal 5, current_state.calculator.working_days_per_week
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
            assert_current_node :hours_per_week_done
            assert_equal "224", current_state.calculator.formatted_full_time_part_time_compressed_hours
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

      context "answer June 1st this year" do
        setup do
          add_response "#{Time.zone.today.year}-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer Jan 1st this year" do
          setup do
            add_response "#{Time.zone.today.year}-01-01"
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
                assert_current_node :hours_per_week_done
                assert_equal "132", current_state.calculator.formatted_full_time_part_time_compressed_hours
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
              assert_current_node :how_many_days_per_week_for_hours?
              add_response "1"
              assert_current_node :how_many_days_per_week_for_hours?, error: true
            end

            # Dept Test 8
            should "be invalid if 77 hours worked over 3 days (dept Test 8)" do
              add_response "77"
              assert_current_node :how_many_days_per_week_for_hours?
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

      context "answer June 1st this year" do
        setup do
          add_response "#{Time.zone.today.year}-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer Jan 1st this year" do
          setup do
            add_response "#{Time.zone.today.year}-01-01"
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
                assert_current_node :hours_per_week_done
                assert_equal "93.7", current_state.calculator.formatted_full_time_part_time_compressed_hours
              end
            end
          end

          # Dept Test 16
          context "impossible working patterns" do
            should "be invalid if 63 hours for 1 day entered (dept Test 16)" do
              add_response "63"
              add_response "1"
              assert_current_node :how_many_days_per_week_for_hours?, error: true
            end
          end
        end
      end

      # Dept Test 18
      context "answer 31 September next year - day that does not exist" do
        setup do
          add_response "#{Time.zone.today.year + 1}-09-31"
        end

        should "ask when the leave year started" do
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

      context "answer 'Jan 20th this year'" do
        setup do
          add_response "#{Time.zone.today.year}-01-20"
        end

        should "ask for the employment end date" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "add leaving_date before start_date" do
          setup do
            add_response "#{Time.zone.today.year - 1}-10-14"
          end

          should "raise an invalid response" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end

        context "answer 'July 18th this year'" do
          setup do
            add_response "#{Time.zone.today.year}-07-18"
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
                assert_current_node :hours_per_week_done
                assert_equal "110.8", current_state.calculator.formatted_full_time_part_time_compressed_hours
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
            assert_equal 224, current_state.calculator.holiday_entitlement_hours
            assert_equal 0, current_state.calculator.holiday_entitlement_minutes
            assert_equal 8, current_state.calculator.hours_daily
            assert_equal 0, current_state.calculator.minutes_daily
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
      context "answer 1 June next year" do
        setup do
          add_response "#{Time.zone.today.year + 1}-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer 1 March last year" do
          setup do
            add_response "#{Time.zone.today.year - 1}-03-01"
          end

          should "be an invalid date" do
            assert_current_node :when_does_your_leave_year_start?, error: true
          end
        end

        # Dept Test 12 - employment cannot start after leave year ends
        context "answer 1 March this year" do
          setup do
            add_response "#{Time.zone.today.year}-03-01"
          end

          should "be an invalid date" do
            assert_current_node :when_does_your_leave_year_start?, error: true
          end
        end
      end

      context "answer June 1st this year" do
        setup do
          add_response "#{Time.zone.today.year}-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer Jan 1st this year" do
          setup do
            add_response "#{Time.zone.today.year}-01-01"
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
                assert_equal 132, current_state.calculator.holiday_entitlement_hours
                assert_equal 0, current_state.calculator.holiday_entitlement_minutes
                assert_equal 8, current_state.calculator.hours_daily
                assert_equal 0, current_state.calculator.minutes_daily
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

      context "answer 1 June next year" do
        setup do
          add_response "#{Time.zone.today.year + 1}-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        # Dept Test 17 - employment cannot start after leave year ends
        context "answer 1 March this year" do
          setup do
            add_response "#{Time.zone.today.year}-03-01"
          end

          should "be an invalid date" do
            assert_current_node :when_does_your_leave_year_start?, error: true
          end
        end

        # Dept Test 18 - employment cannot start after leave year ends
        context "answer 30 May this year" do
          setup do
            add_response "#{Time.zone.today.year}-05-30"
          end

          should "be an invalid date" do
            assert_current_node :when_does_your_leave_year_start?, error: true
          end
        end
      end

      context "answer June 1st for a non-leap year" do
        setup do
          add_response "2017-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer Jan 1st for a non-leap year" do
          setup do
            add_response "2017-01-01"
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
                assert_equal 93, current_state.calculator.holiday_entitlement_hours
                assert_equal 18, current_state.calculator.holiday_entitlement_minutes
                assert_equal 8, current_state.calculator.hours_daily
                assert_equal 0, current_state.calculator.minutes_daily
              end
            end
          end

          context "impossible working patterns" do
            # Dept Test 14
            should "be invalid if 73 hours for 1 day entered (dept Test 14)" do
              add_response "73"
              assert_current_node :how_many_days_per_week_for_hours?, error: false
              add_response "1"
              assert_current_node :how_many_days_per_week_for_hours?, error: true
            end

            # Dept Test 16
            should "be invalid if 40 hours for 1 day entered (dept Test 16)" do
              add_response "40"
              assert_current_node :how_many_days_per_week_for_hours?, error: false
              add_response "1"
              assert_current_node :how_many_days_per_week_for_hours?, error: true
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

      # Dept Test 23 - employment must not extend beyond a year
      context "answer 1 March this year" do
        setup do
          add_response "#{Time.zone.today.year}-03-01"
        end

        should "ask for the employment end date" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "answer 1 June next year" do
          setup do
            add_response "#{Time.zone.today.year + 1}-06-01"
          end

          should "be an invalid date" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end
      end

      context "answer 'Jan 20th' for a non-leap year'" do
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

        context "answer 'July 18th for a non-leap year'" do
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
                assert_equal 110, current_state.calculator.holiday_entitlement_hours
                assert_equal 30, current_state.calculator.holiday_entitlement_minutes
                assert_equal 8, current_state.calculator.hours_daily
                assert_equal 0, current_state.calculator.minutes_daily
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
        assert_equal "5.6", current_state.calculator.formatted_full_time_part_time_weeks
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
          add_response "#{Time.zone.today.year}-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer Jan 1st this year" do
          setup do
            add_response "#{Time.zone.today.year}-01-01"
          end

          should "calculate the holiday entitlement" do
            assert_current_node :irregular_and_annualised_done
            assert_equal "3.27", current_state.calculator.formatted_full_time_part_time_weeks
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
          add_response "#{Time.zone.today.year}-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer Jan 01 this year" do
          setup do
            add_response "#{Time.zone.today.year}-01-01"
          end

          should "calculate the holiday entitlement" do
            assert_equal "2.35", current_state.calculator.formatted_full_time_part_time_weeks
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
          add_response "#{Time.zone.today.year}-01-20"
        end

        should "ask what date employment finished" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "add employment end date before start_date" do
          setup do
            add_response "#{Time.zone.today.year - 1}-10-14"
          end

          should "raise an invalid response" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end

        context "answer June 18th this year" do
          setup do
            add_response "#{Time.zone.today.year}-07-18"
          end

          should "calculate the holiday entitlement" do
            assert_equal "2.77", current_state.calculator.formatted_full_time_part_time_weeks
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
        assert_equal "5.6", current_state.calculator.formatted_full_time_part_time_weeks
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
          add_response "#{Time.zone.today.year}-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer Jan 1st this year" do
          setup do
            add_response "#{Time.zone.today.year}-01-01"
          end

          should "calculate the holiday entitlement" do
            assert_current_node :irregular_and_annualised_done
            assert_equal "3.27", current_state.calculator.formatted_full_time_part_time_weeks
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
          add_response "#{Time.zone.today.year}-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "answer Jan 01 this year" do
          setup do
            add_response "#{Time.zone.today.year}-01-01"
          end

          should "calculate the holiday entitlement" do
            assert_equal "2.35", current_state.calculator.formatted_full_time_part_time_weeks
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
          add_response "#{Time.zone.today.year}-01-20"
        end

        should "ask what date employment finished" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "add employment end date before start_date" do
          setup do
            add_response "#{Time.zone.today.year - 1}-01-20"
          end

          should "raise an invalid response" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end

        context "answer June 18th this year" do
          setup do
            add_response "#{Time.zone.today.year}-07-18"
          end

          should "calculate the holiday entitlement" do
            assert_equal "2.77", current_state.calculator.formatted_full_time_part_time_weeks
            assert_current_node :irregular_and_annualised_done
          end
        end
      end
    end
  end # annualised hours

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

      context "with invalid hours" do
        context "with 0 hours" do
          setup do
            add_response "0"
          end

          should "present an error" do
            assert_current_node :shift_worker_hours_per_shift?, error: true
          end
        end

        context "with over 24 hours" do
          setup do
            add_response "25"
          end

          should "present an error" do
            assert_current_node :shift_worker_hours_per_shift?, error: true
          end
        end
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
              assert_current_node :shift_worker_done

              assert_equal 6, current_state.calculator.hours_per_shift
              assert_equal 8, current_state.calculator.shifts_per_shift_pattern
              assert_equal 14, current_state.calculator.days_per_shift_pattern
              assert_equal "22.4", current_state.calculator.shift_entitlement
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

      # Dept test 10
      context "with invalid dates" do
        setup do
          add_response "#{Time.zone.today.year}-06-20"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          should "be invalid if the start date is not within leave year" do
            add_response "#{Time.zone.today.year - 1}-01-03"
            assert_current_node :when_does_your_leave_year_start?, error: true
          end
        end
      end

      context "with a date" do
        setup do
          add_response "#{Time.zone.today.year}-06-01"
        end

        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Time.zone.today.year}-01-01"
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
                  assert_current_node :shift_worker_done

                  assert_equal 6, current_state.calculator.hours_per_shift
                  assert_equal 8, current_state.calculator.shifts_per_shift_pattern
                  assert_equal 14, current_state.calculator.days_per_shift_pattern
                  assert_equal "13.5", current_state.calculator.shift_entitlement
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
          add_response "#{Time.zone.today.year}-06-01"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Time.zone.today.year}-01-01"
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
                  assert_current_node :shift_worker_done

                  assert_equal 6, current_state.calculator.hours_per_shift
                  assert_equal 8, current_state.calculator.shifts_per_shift_pattern
                  assert_equal 14, current_state.calculator.days_per_shift_pattern
                  assert_equal "9.37", current_state.calculator.shift_entitlement
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
          add_response "#{Time.zone.today.year}-01-20"
        end

        should "ask for the employment end date" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "add employment end date before start_date" do
          setup do
            add_response "#{Time.zone.today.year - 1}-01-20"
          end

          should "raise an invalid response" do
            assert_current_node :what_is_your_leaving_date?, error: true
          end
        end

        context "with a leaving date" do
          setup do
            add_response "#{Time.zone.today.year}-07-18"
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
                  assert_current_node :shift_worker_done

                  assert_equal 6, current_state.calculator.hours_per_shift
                  assert_equal 8, current_state.calculator.shifts_per_shift_pattern
                  assert_equal 14, current_state.calculator.days_per_shift_pattern
                  assert_equal "11.08", current_state.calculator.shift_entitlement
                end
              end
            end
          end
        end # with a leave year start date
      end # with a date
    end # leaving this year
  end # shift worker
end
