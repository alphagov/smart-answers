require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/calculate-statutory-sick-pay"

class CalculateStatutorySickPayTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateStatutorySickPayFlow
  end

  context "Getting statutory maternity pay" do
    should "go to result A1" do
      add_response "statutory_maternity_pay"
      assert_current_node :already_getting_maternity # A1
    end
  end

  context "Getting maternity allowance" do
    should "go to result A1" do
      add_response "maternity_allowance"
      assert_current_node :already_getting_maternity # A1
    end
  end

  context "Not getting maternity allowance" do
    setup do
      add_response "ordinary_statutory_paternity_pay,statutory_adoption_pay"
    end

    should "set adoption warning state variable" do
      assert_state_variable :paternity_maternity_warning, true
    end
    should "take you to Q2" do
      assert_current_node :employee_tell_within_limit? # Q2
    end
  end

  context "Getting additional statutory paternity pay" do
    setup do
      add_response "additional_statutory_paternity_pay"
    end

    should "set adoption warning state variable" do
      assert_state_variable :paternity_maternity_warning, true
    end

    should "take you to Q2" do
      assert_current_node :employee_tell_within_limit? # Q2
    end

    context "employee didn't tell employer within time limit" do
      setup do
        add_response :no
      end

      should "go to entitled_to_sick_pay outcome" do
        assert_current_node :employee_work_different_days?
        add_response :no
        assert_current_node :first_sick_day?
        add_response '2014-03-02'
        assert_current_node :last_sick_day?
        add_response '2014-06-02'
        assert_current_node :has_linked_sickness?
        add_response 'no'
        assert_current_node :paid_at_least_8_weeks?
        add_response 'before_payday'
        assert_current_node :how_often_pay_employee_pay_patterns?
        add_response 'irregularly'
        assert_current_node :pay_amount_if_not_sick?
        add_response '3000'
        assert_current_node :contractual_days_covered_by_earnings?
        add_response '17'
        assert_current_node :usual_work_days?
        add_response '1,2,3,4,5'
        assert_current_node :entitled_to_sick_pay
        assert_phrase_list :proof_of_illness, [:enough_notice]
        assert_phrase_list :paternity_adoption_warning, [:paternity_warning]
      end
    end

    context "employee told employer within time limit" do
      setup do
        add_response :yes
      end

      should "take you to Q3" do
        assert_current_node :employee_work_different_days? # Q3
      end

      context "employee works different days of the week" do
        setup do
          add_response :yes
        end
        should "go to result A4" do
          assert_current_node :not_regular_schedule # A4
        end
      end

      context "employee works regular days" do
        should "require to be sick more than 4 days to get sick pay" do
          add_response :no
          assert_current_node :first_sick_day? # Q4
          add_response '2013-04-02'
          assert_state_variable :sick_start_date, Date.parse(' 2 April 2013')
          assert_current_node :last_sick_day? # Q5

          add_response '2013-04-04'
          assert_current_node :must_be_sick_for_4_days # A2
        end

        should "lead to entitled_to_sick_pay outcome when there is a linked sickness" do
          add_response :no
          assert_current_node :first_sick_day? # Q4
          add_response '2013-04-02'
          assert_state_variable :sick_start_date, Date.parse(' 2 April 2013')
          assert_current_node :last_sick_day? # Q5
          add_response '2013-04-10'
          assert_state_variable :sick_end_date, Date.parse('10 April 2013')
          assert_current_node :has_linked_sickness?
          add_response 'no'
          assert_current_node :paid_at_least_8_weeks?
          add_response 'eight_weeks_more'
          assert_current_node :how_often_pay_employee_pay_patterns?
          assert_state_variable :eight_weeks_earnings, 'eight_weeks_more'
          add_response 'weekly'
          assert_current_node :last_payday_before_sickness?
          assert_state_variable :pay_pattern, 'weekly'
          add_response '2013-03-31'
          assert_current_node :last_payday_before_offset?
          add_response '2013-01-31'
          assert_current_node :total_employee_earnings?
          add_response '4000'
          assert_current_node :usual_work_days?
          add_response '1,2,3,4,5'
          assert_current_node :entitled_to_sick_pay
        end

        should "lead to entitled_to_sick_pay without first days when there is no linked sickness" do
          add_response :no
          assert_current_node :first_sick_day? # Q4
          add_response '2013-04-02'
          assert_state_variable :sick_start_date, Date.parse(' 2 April 2013')
          assert_current_node :last_sick_day? # Q5

          add_response '2013-04-10'
          assert_state_variable :sick_end_date, Date.parse('10 April 2013')
          assert_current_node :has_linked_sickness?
          add_response 'no'
          assert_current_node :paid_at_least_8_weeks?
          add_response 'eight_weeks_more'
          assert_current_node :how_often_pay_employee_pay_patterns?
          assert_state_variable :eight_weeks_earnings, 'eight_weeks_more'
          add_response 'weekly'
          assert_current_node :last_payday_before_sickness?
          assert_state_variable :pay_pattern, 'weekly'
          add_response '2013-03-31'
          assert_current_node :last_payday_before_offset?
          add_response '2013-01-31'
          assert_current_node :total_employee_earnings?
          add_response '4000'
          assert_current_node :usual_work_days?
          add_response '1,2,3,4,5'
          assert_current_node :entitled_to_sick_pay
          assert_phrase_list :entitled_to_esa, [:esa]
          assert_phrase_list :paternity_adoption_warning, [:paternity_warning]
        end

        should "lead to entitled_to_sick_pay if worker got sick before payday and had linked sickness" do
          add_response :no
          assert_current_node :first_sick_day? # Q4
          add_response '2013-04-02'
          assert_state_variable :sick_start_date, Date.parse(' 2 April 2013')
          assert_current_node :last_sick_day? # Q5
          add_response '2013-04-10'
          assert_state_variable :sick_end_date, Date.parse('10 April 2013')
          assert_current_node :has_linked_sickness?
          add_response 'yes'
          assert_current_node :linked_sickness_start_date?
          add_response '2013-03-12'
          assert_current_node :linked_sickness_end_date?
          add_response '2013-03-16'
          assert_current_node :paid_at_least_8_weeks?
          add_response 'before_payday'
          assert_current_node :how_often_pay_employee_pay_patterns?
          add_response 'monthly'
          assert_current_node :pay_amount_if_not_sick?
          add_response '2000'
          assert_current_node :contractual_days_covered_by_earnings?
          add_response '30'
          assert_current_node :usual_work_days?
          add_response '1,2,3'
          assert_current_node :entitled_to_sick_pay
        end

        should "lead to entitled_to_sick_pay if worker got sick before payday and had no linked sickness" do
          add_response :no
          assert_current_node :first_sick_day? # Q4
          add_response '2013-04-02'
          assert_state_variable :sick_start_date, Date.parse(' 2 April 2013')
          assert_current_node :last_sick_day? # Q5
          add_response '2013-04-10'
          assert_state_variable :sick_end_date, Date.parse('10 April 2013')
          assert_current_node :has_linked_sickness?
          add_response 'no'
          assert_current_node :paid_at_least_8_weeks?
          add_response 'before_payday'
          assert_current_node :how_often_pay_employee_pay_patterns?
          add_response 'monthly'
          assert_current_node :pay_amount_if_not_sick?
          add_response '2000'
          assert_current_node :contractual_days_covered_by_earnings?
          add_response '30'
          assert_current_node :usual_work_days?
          add_response '1,2,3,4,5'
          assert_current_node :entitled_to_sick_pay
        end

        should "lead to entitled_to_sick_pay if worker got sick before being employed for 8 weeks and had linked sickness" do
          add_response :no
          assert_current_node :first_sick_day? # Q4
          add_response '2013-04-02'
          assert_state_variable :sick_start_date, Date.parse(' 2 April 2013')
          assert_current_node :last_sick_day? # Q5
          add_response '2013-04-10'
          assert_state_variable :sick_end_date, Date.parse('10 April 2013')
          assert_current_node :has_linked_sickness?
          add_response 'yes'
          assert_current_node :linked_sickness_start_date?
          add_response '2013-03-24'
          assert_current_node :linked_sickness_end_date?
          add_response '2013-03-29'
          assert_current_node :paid_at_least_8_weeks?
          add_response :eight_weeks_less
          assert_current_node :total_earnings_before_sick_period?
          add_response '3000'
          assert_current_node :days_covered_by_earnings?
          add_response '35'
          assert_current_node :usual_work_days?
          add_response '1,2,3,4,5'
          assert_current_node :entitled_to_sick_pay
        end

        should "lead to entitled_to_sick_pay if worker got sick before being employed for 8 weeks and had no linked sickness" do
          add_response :no
          assert_current_node :first_sick_day? # Q4
          add_response '2013-04-02'
          assert_state_variable :sick_start_date, Date.parse(' 2 April 2013')
          assert_current_node :last_sick_day? # Q5
          add_response '2013-04-10'
          assert_state_variable :sick_end_date, Date.parse('10 April 2013')
          assert_current_node :has_linked_sickness?
          add_response 'no'
          assert_current_node :paid_at_least_8_weeks?
          add_response :eight_weeks_less
          assert_current_node :total_earnings_before_sick_period?
          add_response '3000'
          assert_current_node :days_covered_by_earnings?
          add_response '35'
          assert_current_node :usual_work_days?
          add_response '1,2,3,4,5'
          assert_current_node :entitled_to_sick_pay
        end
      end
    end
  end

  context "average weekly earnings is less than the LEL on sick start date" do
    setup do
      add_response 'none' # Q1
      add_response 'yes' # Q2
      add_response 'no' # Q3
      add_response '2013-06-10' # Q4
      add_response '2013-06-20' # Q5
      add_response 'no' # Q11
      add_response 'before_payday' # Q5.1
      add_response 'weekly' # Q5.2
      add_response '100' # Q7
      add_response '7' # Q7.1
      add_response '1,2,3,4,5' # Q13
    end
    should "take you to result A5 as awe < LEL (as of 2013-06-10)" do
      assert_state_variable :employee_average_weekly_earnings, 100
      assert_current_node :not_earned_enough
    end
  end

  context "no SSP payable as sickness period is < 4 days" do
    setup do
      add_response 'none'
      add_response 'yes'
      add_response 'no'
      add_response '2013-06-10'
      add_response '2013-06-12'
    end
    should "take you to result A7 - must be sick for at least 4 days in a row" do
      assert_current_node :must_be_sick_for_4_days
    end
  end

  context "no SSP payable as already had maximum" do
    should "take you to result A8 as already claimed > 28 weeks (max amount)" do
      add_response 'none'
      assert_current_node :employee_tell_within_limit?
      add_response 'yes'
      assert_current_node :employee_work_different_days?
      add_response 'no'
      assert_current_node :first_sick_day?
      add_response '2014-10-10'
      assert_current_node :last_sick_day?
      add_response '2014-10-20'
      assert_current_node :has_linked_sickness?
      add_response 'yes'
      assert_current_node :linked_sickness_start_date?
      add_response '2014-05-01'
      assert_current_node :linked_sickness_end_date?
      add_response '2014-09-20'
      assert_current_node :paid_at_least_8_weeks?
      add_response 'eight_weeks_more'
      assert_current_node :how_often_pay_employee_pay_patterns?
      add_response 'monthly'
      assert_current_node :last_payday_before_sickness?
      add_response '2013-04-01'
      assert_current_node :last_payday_before_offset?
      add_response '2013-02-3'
      assert_current_node :total_employee_earnings?
      add_response '4000'
      assert_current_node :usual_work_days?
      add_response '1,2,3,4,5'

      assert_current_node :maximum_entitlement_reached
    end
  end

  context "tabular output for final SSP calculation" do
    should "have the adjusted rates in place for the week crossing through 6th April" do
      add_response :ordinary_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response "2013-01-08"
      add_response "2013-05-03"
      add_response :yes
      add_response "2013-01-07"
      add_response "2013-01-15"
      add_response :eight_weeks_more
      add_response :monthly
      add_response "2012-12-28"
      add_response "2012-10-26"
      add_response 1600.0
      add_response "3,6"

      assert_current_node :entitled_to_sick_pay
      assert_state_variable :formatted_sick_pay_weekly_amounts,
                            ["12 January 2013|£85.85",
                             "19 January 2013|£85.85",
                             "26 January 2013|£85.85",
                             " 2 February 2013|£85.85",
                             " 9 February 2013|£85.85",
                             "16 February 2013|£85.85",
                             "23 February 2013|£85.85",
                             " 2 March 2013|£85.85",
                             " 9 March 2013|£85.85",
                             "16 March 2013|£85.85",
                             "23 March 2013|£85.85",
                             "30 March 2013|£85.85",
                             " 6 April 2013|£86.28",
                             "13 April 2013|£86.70",
                             "20 April 2013|£86.70",
                             "27 April 2013|£86.70",
                             " 4 May 2013|£43.35"].join("\n")
    end

    should "have consistent rates for all weekly rates that are produced" do
      add_response :ordinary_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response "2013-01-08"
      add_response "2013-05-03"
      add_response :yes
      add_response "2013-01-07"
      add_response "2013-02-03"
      add_response :eight_weeks_more
      add_response :monthly
      add_response "2012-12-28"
      add_response "2012-10-26"
      add_response 1250.75
      add_response "2,3,4"

      assert_current_node :entitled_to_sick_pay
      assert_state_variable :formatted_sick_pay_weekly_amounts,
                            ["12 January 2013|£85.85",
                             "19 January 2013|£85.85",
                             "26 January 2013|£85.85",
                             " 2 February 2013|£85.85",
                             " 9 February 2013|£85.85",
                             "16 February 2013|£85.85",
                             "23 February 2013|£85.85",
                             " 2 March 2013|£85.85",
                             " 9 March 2013|£85.85",
                             "16 March 2013|£85.85",
                             "23 March 2013|£85.85",
                             "30 March 2013|£85.85",
                             " 6 April 2013|£85.85",
                             "13 April 2013|£86.70",
                             "20 April 2013|£86.70",
                             "27 April 2013|£86.70",
                             " 4 May 2013|£86.70"].join("\n")
    end

    should "show formatted weekly payment amounts with adjusted 3 days start amount for ordinary SPP" do
      add_response :ordinary_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response "2013-01-07"
      add_response "2013-05-03"
      add_response :no
      add_response :eight_weeks_more
      add_response :irregularly
      add_response "2012-12-28"
      add_response "2012-10-26"
      add_response 3000.0
      add_response "1,2,3,4"

      assert_current_node :entitled_to_sick_pay
      assert_state_variable :formatted_sick_pay_weekly_amounts,
                            ["12 January 2013|£21.47",
                             "19 January 2013|£85.85",
                             "26 January 2013|£85.85",
                             " 2 February 2013|£85.85",
                             " 9 February 2013|£85.85",
                             "16 February 2013|£85.85",
                             "23 February 2013|£85.85",
                             " 2 March 2013|£85.85",
                             " 9 March 2013|£85.85",
                             "16 March 2013|£85.85",
                             "23 March 2013|£85.85",
                             "30 March 2013|£85.85",
                             " 6 April 2013|£85.85",
                             "13 April 2013|£86.70",
                             "20 April 2013|£86.70",
                             "27 April 2013|£86.70",
                             " 4 May 2013|£86.70"].join("\n")
    end

    should "show formatted weekly payment amounts with adjusted 3 days start amount for additional SPP" do
      add_response :additional_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response "2013-01-07"
      add_response "2013-05-03"
      add_response :no
      add_response :eight_weeks_more
      add_response :irregularly
      add_response "2012-12-28"
      add_response "2012-10-26"
      add_response 3000.0
      add_response "1,2,3,4"

      assert_current_node :entitled_to_sick_pay
      assert_state_variable :formatted_sick_pay_weekly_amounts,
                            ["12 January 2013|£21.47",
                             "19 January 2013|£85.85",
                             "26 January 2013|£85.85",
                             " 2 February 2013|£85.85",
                             " 9 February 2013|£85.85",
                             "16 February 2013|£85.85",
                             "23 February 2013|£85.85",
                             " 2 March 2013|£85.85",
                             " 9 March 2013|£85.85",
                             "16 March 2013|£85.85",
                             "23 March 2013|£85.85",
                             "30 March 2013|£85.85",
                             " 6 April 2013|£85.85",
                             "13 April 2013|£86.70",
                             "20 April 2013|£86.70",
                             "27 April 2013|£86.70",
                             " 4 May 2013|£86.70"].join("\n")
    end
  end

  context "first_sick_day? date validation" do
    setup do
      add_response :additional_statutory_paternity_pay
      add_response :no
      add_response :no
      assert_current_node :first_sick_day?
    end

    should "not allow dates before 2011" do
      add_response Date.parse("2010-12-31")
      assert_current_node_is_error
    end

    should "not allow dates next year" do
      add_response (Date.today.end_of_year + 1.day).to_s
      assert_current_node_is_error
    end
  end

  context "last_sick_day? date validation" do
    setup do
      add_response :additional_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response "02/04/2013"
      assert_current_node :last_sick_day?
    end

    should "not allow dates before 2012" do
      add_response Date.parse("2011-12-31")
      assert_current_node_is_error
    end

    should "not allow dates next year" do
      add_response (Date.today.end_of_year + 1.day).to_s
      assert_current_node_is_error
    end

    should "not allow dates before start_date" do
      add_response "01/04/2013"
      assert_current_node_is_error
    end
  end

  context "linked_sickness_start_date? date validation" do
    setup do
      add_response :additional_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response "2015-03-19"
      add_response "2015-03-27"
      add_response :yes
      assert_current_node :linked_sickness_start_date?
    end

    should "not allow dates before 2010" do
      add_response Date.parse("2009-12-31")
      assert_current_node_is_error
    end

    should "not allow dates next year" do
      add_response (Date.today.end_of_year + 1.day).to_s
      assert_current_node_is_error
    end

    should "only allow linked sickness to be before the recent one" do
      add_response "2015-03-20"
      assert_current_node_is_error "linked_sickness_must_be_before"
    end
  end

  context "linked_sickness_end_date? date validation" do
    setup do
      add_response :additional_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response "2015-05-21"
      add_response "2015-05-29"
      add_response :yes
      add_response "2015-03-20"
      assert_current_node :linked_sickness_end_date?
      @furthest_linked_sickness_end_date = Date.parse("2015-03-27") # (Date.parse("2015-05-21") - 8.weeks).tomorrow
    end

    should "not allow dates before 2010" do
      add_response Date.parse("2009-12-31")
      assert_current_node_is_error
    end

    should "not allow dates next year" do
      add_response (Date.today.end_of_year + 1.day).to_s
      assert_current_node_is_error
    end

    should "not allow dates before start_date" do
      add_response "2013-01-31"
      assert_current_node_is_error
    end

    should "allow the latest allowed end date" do
      add_response @furthest_linked_sickness_end_date.to_s
      assert_current_node :paid_at_least_8_weeks?
    end

    should "not allow a day before the latest allowed date" do
      add_response (@furthest_linked_sickness_end_date - 1.day).to_s
      assert_current_node_is_error "must_be_within_eight_weeks"
    end
  end

  context "last_payday_before_sickness? date validation" do
    setup do
      add_response :additional_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response "02/04/2013"
      add_response "10/04/2013"
      add_response :no
      add_response "eight_weeks_more"
      add_response "weekly"
      assert_current_node :last_payday_before_sickness?
    end

    should "not allow dates before 2010" do
      add_response Date.parse("2009-12-31")
      assert_current_node_is_error
    end

    should "not allow dates next year" do
      add_response (Date.today.end_of_year + 1.day).to_s
      assert_current_node_is_error
    end
  end

  context "last_payday_before_offset? date validation" do
    setup do
      add_response :additional_statutory_paternity_pay
      add_response :yes
      add_response :no
      add_response "02/04/2013"
      add_response "10/04/2013"
      add_response :no
      add_response "eight_weeks_more"
      add_response "weekly"
      add_response "31/03/2013"
      assert_current_node :last_payday_before_offset?
    end

    should "not allow dates before 2010" do
      add_response Date.parse("2009-12-31")
      assert_current_node_is_error
    end

    should "not allow dates next year" do
      add_response (Date.today.end_of_year + 1.day).to_s
      assert_current_node_is_error
    end
  end
end
