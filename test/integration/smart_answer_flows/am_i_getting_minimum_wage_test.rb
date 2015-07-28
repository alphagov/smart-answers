require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/am-i-getting-minimum-wage"

class AmIGettingMinimumWageTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::AmIGettingMinimumWageFlow
  end

  # Q1
  should "ask 'what would you like to check?'" do
    assert_current_node :what_would_you_like_to_check?
  end

  # Current payments
  #
  context "when checking current pay" do
    setup do
      add_response :current_payment
    end

    # Q2
    should "ask 'are you an apprentice?'" do
      assert_current_node :are_you_an_apprentice?
    end

    context "answered 'apprentice under 19' to 'are you an apprentice?'" do
      setup do
        add_response :apprentice_under_19
      end
      should "ask 'how often do you get paid?'" do
        assert_current_node :how_often_do_you_get_paid?
      end
    end

    context "answered 'apprentice over 19 on first year' to 'are you an apprentice?'" do
      setup do
        add_response :apprentice_over_19_first_year
      end
      should "ask 'how often do you get paid?'" do
        assert_current_node :how_often_do_you_get_paid?
      end
    end

    context "answered 'apprentice over 19 on second year or onwards' to 'are you an apprentice?'" do
      setup do
        add_response :apprentice_over_19_second_year_onwards
      end
      should "ask 'how often do you get paid?'" do
        assert_current_node :how_old_are_you?
      end
      context "treat the user as a non apprentice'" do
        setup do
          add_response 22
          add_response 20
          add_response 120
          add_response 30
          add_response 0
          add_response "no"
        end
        should "show current minimum wage rate" do
          assert_state_variable "minimum_hourly_rate", 6.50
        end
      end
    end

    context "answered 'no' to 'are you an apprentice?'" do
      # Q3

      setup do
        add_response :not_an_apprentice
      end

      should "ask 'how old are you?'" do
        assert_current_node :how_old_are_you?
      end

      context "answered 15 to 'how old are you?'" do
        setup {add_response 15}

        should "display under school leaving age outcome" do
          assert_current_node :under_school_leaving_age
        end
      end

      context "answer invalid for Q3 how old" do
        should "not accept 0 age" do
          add_response 0
          assert_current_node :how_old_are_you?, error: true
        end

        should "not accept age > 200" do
          add_response 250
          assert_current_node :how_old_are_you?, error: true
        end

      end

      context "answered 19 to 'how old are you?'" do
        setup do
          add_response 19
        end

        # Q4
        should "ask 'how often do you get paid?'" do
          assert_current_node :how_often_do_you_get_paid?
        end

        context "answered weekly to 'how often do you get paid?'" do
          setup do
            add_response 7
          end

          # Q5
          should "ask 'how many hours do you work?'" do
            assert_current_node :how_many_hours_do_you_work?
          end

          context "test hours entry for hours worked" do
            should "succeed on 37.5 entered" do
              add_response "37.5"
              assert_current_node :how_much_are_you_paid_during_pay_period?
            end
            should "fail on text entered" do
              add_response "no numbers"
              assert_current_node_is_error
            end
            should "fail if 0 entered" do
              add_response "0"
              assert_current_node_is_error
            end
            should "succeed on 0.01 entered" do
              add_response "0.01"
            end
          end

          context "answered 'how many hours do you work?'" do
            setup do
              add_response 42
            end

            # Q6
            should "ask 'how much do you get paid?'" do
              assert_current_node :how_much_are_you_paid_during_pay_period?
            end

            context "answer '0' to 'how much do you get paid?'" do
              setup do
                add_response 0
              end
              should "go to overtime questions" do
                assert_current_node :how_many_hours_overtime_do_you_work?
              end
            end

            context "answered 158.39 to 'how much do you get paid?'" do
              setup do
                add_response 158.39
              end

              # Q7
              should "ask 'how many hours overtime?'" do
                assert_current_node :how_many_hours_overtime_do_you_work?
              end

              context "answer '8 hours' to 'how many hours overtime?'" do
                setup do
                  add_response 8
                end

                # Q8
                should "ask 'what rate of overtime per hour?'" do
                  assert_current_node :what_is_overtime_pay_per_hour?
                end

                context "answer 3.71 to 'overtime per hour?'" do
                  setup do
                    add_response 3.71
                  end
                  # Q9
                  should "ask 'are you provided with accommodation?'" do
                    assert_current_node :is_provided_with_accommodation?
                  end

                  context "answer 'no'" do
                    setup do
                      add_response :no
                    end

                    should "show the results" do
                      assert_current_node :current_payment_below
                    end
                  end
                end
              end

              context "answer 'no overtime' to 'how many hours overtime?'" do
                setup do
                  add_response 0
                end

                # Q9
                should "ask 'are you provided with accommodation?'" do
                  assert_current_node :is_provided_with_accommodation?
                end

                context "answer 'no' to 'are you provided with accommodation?'" do
                  setup do
                    add_response :no
                  end

                  should "show the results" do
                    assert_current_node :current_payment_below
                  end
                end

                # Where accommodation is charged under the £4.73 threshold.
                # No adjustment is made to basic pay.
                #
                context "answer 'yes charged accommodation' to 'are you provided with accommodation?'" do
                  setup do
                    add_response :yes_charged
                  end

                  # Q10
                  should "ask 'how much do you pay for the accommodation?'" do
                    assert_current_node :current_accommodation_charge?
                  end

                  context "answer 4.72 to 'how much do you pay for accommodation?'" do
                    setup do
                      add_response 4.72
                    end

                    should "ask 'how often do you use the accommodation?'" do
                      assert_current_node :current_accommodation_usage?
                    end

                    context "answer 4 to 'how often do you use the accommodation?'" do
                      setup do
                        add_response 4
                      end

                      should "show below min. wage results" do
                        assert_current_node :current_payment_below
                      end
                    end
                  end # Accommodation
                end # Overtime rate
              end # Overtime hours
            end # Basic pay

            # Again with a better basic pay to achieve > min. wage.
            #
            context "answer '300' to 'how much do you get paid?'" do
              setup do
                add_response 300
                add_response 0 # overtime hours
                add_response :no # no accommodation
              end
              should "show above min. wage results" do
                assert_current_node :current_payment_above
              end
            end # Basic pay
          end # Basic hours
        end # Pay frequency
      end # Age

      # Scenario 8
      context "25 year old" do
        setup do
          add_response 25
          add_response 7
          add_response 35
          add_response 350
          add_response 10
          add_response 12
          add_response :yes_charged
          add_response 30
          add_response 7
        end
        should "be below the minimum wage" do
          assert_current_node :current_payment_below
        end
        should "make outcome calculations" do
          assert_state_variable "total_hours", 45
          assert_state_variable "minimum_hourly_rate", 6.50
          assert_state_variable "total_hourly_rate", 6.12
          assert_state_variable "above_minimum_wage", false
        end
      end

      # test minimum wage rates
      context "22 years old, 2013-2014 minimum wage" do
        setup do
          Timecop.travel('30 Sep 2014')
          add_response 22
          add_response 20
          add_response 120
          add_response 30
          add_response 0
          add_response "no"
        end
        should "show current minimum wage rate" do
          assert_state_variable "minimum_hourly_rate", 6.31
        end
      end

      context "22 years old, 2014-2015 minimum wage" do
        setup do
          Timecop.travel('01 Oct 2014')
          add_response 22
          add_response 20
          add_response 120
          add_response 30
          add_response 0
          add_response "no"
        end
        should "show current minimum wage rate" do
          assert_state_variable "minimum_hourly_rate", 6.50
        end
      end

      # Scenario 8 - part 2 - living in free accommodation instead of charged
      context "25 year old, living in free accommodation" do
        setup do
          add_response 25         # age
          add_response 7          # pay_frequency
          add_response 35         # basic_hours
          add_response 350        # amount_paid
          add_response 10         # hours of overtime
          add_response 12         # overtime pay per hour
          add_response :yes_free  # provided accomodation
          add_response 7          # accom usage
        end
        should "be above the minimum wage" do
          assert_current_node :current_payment_above
        end
        should "make outcome calculations" do
          assert_state_variable "total_hours", 45
          # NOTE: these are date sensitive vars - will be tested in the calculator tests
          # assert_state_variable "minimum_hourly_rate", 6.08 #
          # assert_state_variable "total_hourly_rate", "10.74" # time sensitive
          assert_state_variable "above_minimum_wage", true
        end
      end
    end # Apprentice
  end # Current pay

  # Past payments
  #
  context "when checking past pay" do
    setup do
      Timecop.travel('30 Sep 2013')
      add_response :past_payment
    end

    should "ask 'which date do you want to check?'" do
      assert_current_node :past_payment_date?
    end

    context "answer 2009-10-01" do
      setup do
        add_response "2009-10-01"
      end

      # Q2
      should "ask 'were you an apprentice?'" do
        assert_current_node :were_you_an_apprentice?
      end

      context "answered 'apprentice under 19' to 'are you an apprentice?'" do
        setup do
          add_response :apprentice_over_19
        end
        should "ask 'how often did you get paid?'" do
          assert_current_node :does_not_apply_to_historical_apprentices
        end
      end

      context "answered 'apprentice over 19' to 'were you an apprentice?'" do
        setup do
          add_response :apprentice_over_19
        end
        should "ask 'how often did you get paid?'" do
          assert_current_node :does_not_apply_to_historical_apprentices
        end

      end

      context "answered 'no' to 'were you an apprentice?'" do
        # Q3

        setup do
          add_response :no
        end

        should "ask 'how old were you?'" do
          assert_current_node :how_old_were_you?
        end

        context "answered 19 to 'how old were you?'" do
          setup do
            add_response 19
          end

          # Q4
          should "ask 'how often did you get paid?'" do
            assert_current_node :how_often_did_you_get_paid?
          end

          context "answered weekly to 'how often did you get paid?'" do
            setup do
              add_response "7"
            end

            # Q5
            should "ask 'how many hours did you work?'" do
              assert_current_node :how_many_hours_did_you_work?
            end

          context "test hours entry for hours worked" do
            should "succeed on 37.5 entered" do
              add_response "37.5"
              assert_current_node :how_much_were_you_paid_during_pay_period?
            end
            should "fail on text entered" do
              add_response "no numbers"
              assert_current_node_is_error
            end
            should "fail if 0 entered" do
              add_response "0"
              assert_current_node_is_error
            end
            should "succeed on 0.01 entered" do
              add_response "0.01"
            end
          end

            context "answered 'how many hours did you work?'" do
              setup do
                add_response 42
              end

              # Q6
              should "ask 'how much did you get paid?'" do
                assert_current_node :how_much_were_you_paid_during_pay_period?
              end

              context "answered 158.39 to 'how much did you get paid?'" do
                setup do
                  add_response 158.39
                end

                # Q7
                should "ask 'how many hours overtime?'" do
                  assert_current_node :how_many_hours_overtime_did_you_work?
                end

                context "answer '8 hours' to 'how many hours overtime?'" do
                  setup do
                    add_response 8
                  end

                  # Q8
                  should "ask 'what rate of overtime per hour?'" do
                    assert_current_node :what_was_overtime_pay_per_hour?
                  end

                  context "answer 3.71 to 'overtime per hour?'" do
                    # Q9
                    should "ask 'were you provided with accommodation?'" do
                      add_response 3.71
                      assert_current_node :was_provided_with_accommodation?
                    end
                  end
                end

                context "answer 'no overtime' to 'how many hours overtime?'" do
                  setup do
                    add_response 0
                  end

                  # Q9
                  should "ask 'were you provided with accommodation?'" do
                    assert_current_node :was_provided_with_accommodation?
                  end

                  context "answer 'no' to 'were you provided with accommodation?'" do
                    setup do
                      add_response :no
                    end

                    should "show the results" do
                      assert_current_node :past_payment_below
                      # assert_current_node :past_payment_above
                    end

                  end

                  # Where accommodation is charged under the £4.73 threshold.
                  # No adjustment is made to basic pay.
                  #
                  context "answer 'yes charged accommodation' to 'were you provided with accommodation?'" do
                    setup do
                      add_response :yes_charged
                    end

                    # Q10
                    should "ask 'how much did you pay for the accommodation?'" do
                      assert_current_node :past_accommodation_charge?
                    end

                    context "answer 4.72 to 'how much did you pay for accommodation?'" do
                      setup do
                        add_response 4.72
                      end

                      should "ask 'how often did you use the accommodation?'" do
                        assert_current_node :past_accommodation_usage?
                      end

                      context "answer 4 to 'how often did you use the accommodation?'" do
                        setup do
                          add_response 4
                        end

                        should "show results" do
                          assert_current_node :past_payment_below
                        end

                        should "make outcome calculations" do
                          assert_state_variable "total_hours", 42
                          assert_state_variable "minimum_hourly_rate", 4.83
                          assert_state_variable "total_hourly_rate", 3.75
                          assert_state_variable "above_minimum_wage", false
                        end
                      end
                    end
                  end
                end
              end

              # Again with a better basic pay to achieve < min. wage.
              #
              context "answer '200' to 'how much did you get paid?'" do
                setup do
                  add_response 200
                  add_response 0 # overtime hours
                  add_response :no # no accommodation
                end
                should "show above min. wage results" do
                  # assert_current_node :past_payment_above
                  assert_current_node :past_payment_below
                end
              end # Basic pay
            end # Basic hours
          end # Pay frequency
        end # Age
      end # Apprentice
    end # Date in question

    # Test for alternative historical apprentice outcome
    #
    context "answer 2010-10-01" do
      setup do
        add_response '2010-10-01'
        add_response :apprentice_over_19
      end

      should "ask 'how often did you get paid?'" do
        assert_current_node :how_often_did_you_get_paid?
      end
    end

    # Scenario 12 from spreadsheet
    context "17 year old in 2008-09" do
      setup do
        add_response Date.parse("2008-10-01")
        add_response :no
        add_response 17 # age at the time
        add_response 30 # pay frequency
        add_response 210 # basic hours
        add_response 840  # basic pay
        add_response 0   # overtime hours
      end
      # Scenario 12 in free accommodation
      context "living in free accommodation" do
        setup do
          add_response :yes_free # accommodation type
          add_response 5   # days per week in accommodation
        end
        should "be above the minimum wage" do
          assert_current_node :past_payment_above
        end
        should "make outcome calculations" do
          assert_state_variable "total_hours", 210
          assert_state_variable "minimum_hourly_rate", 3.53
          assert_state_variable "total_hourly_rate", 4.46
          assert_state_variable "above_minimum_wage", true
          assert_state_variable "historical_adjustment", 0
        end
      end
      # Scenario 12 in accommodation charged above the threshold
      context "living in charged accommodation" do
        setup do
          add_response :yes_charged
          add_response 10  # accommodation cost
          add_response 7   # days per week in accommodation
        end
        should "be below the minimum wage" do
          assert_current_node :past_payment_below
        end
        should "make outcome calculations" do
          assert_state_variable "total_hours", 210
          assert_state_variable "minimum_hourly_rate", 3.53
          assert_state_variable "total_hourly_rate", 3.21
          assert_state_variable "above_minimum_wage", false
          assert_state_variable "historical_adjustment", 70.38
        end
      end

    end
  end # Past pay

  context "when underpayed by employer" do
    setup do
      Timecop.travel('2015-07-01')
    end

    should "adjust underpayment based on the current rate" do
      assert_current_node :what_would_you_like_to_check?
      add_response 'past_payment'

      assert_current_node :past_payment_date?
      add_response '2011-10-01'

      assert_current_node :were_you_an_apprentice?
      add_response 'no'

      assert_current_node :how_old_were_you?
      add_response '25'

      assert_current_node :how_often_did_you_get_paid?
      add_response '7'

      assert_current_node :how_many_hours_did_you_work?
      add_response '40'

      assert_current_node :how_much_were_you_paid_during_pay_period?
      add_response '200'

      assert_current_node :how_many_hours_overtime_did_you_work?
      add_response '0'

      assert_current_node :was_provided_with_accommodation?
      add_response 'no'

      assert_current_node :past_payment_below
      assert_state_variable :minimum_hourly_rate, 6.08 # rate on '2011-10-01'

      expected_underpayment = 46.18
      # (hours worked * hourly rate back then - paid by employer) / minimum hourly rate back then * minimum hourly rate today
      # (40h * £6.08 - £200.0) / 6.08 * 6.50 = 46.18
      assert_state_variable :total_underpayment, expected_underpayment
    end
  end
end
