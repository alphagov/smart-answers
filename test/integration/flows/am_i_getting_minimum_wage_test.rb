require_relative "../../test_helper"
require_relative "flow_integration_test_helper"

class AmIGettingMinimumWageTest < ActiveSupport::TestCase
  include FlowIntegrationTestHelper

  setup do
    travel_to(Date.parse("2015-01-01"))
    setup_for_testing_flow AmIGettingMinimumWageFlow
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
          assert_equal 6.50, current_state.calculator.minimum_hourly_rate
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
        setup { add_response 15 }

        should "display under school leaving age outcome" do
          assert_current_node :under_school_leaving_age
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
              should "go to accomodation questions" do
                assert_current_node :is_provided_with_accommodation?
              end
            end

            context "answered 158.39 to 'how much do you get paid?'" do
              setup do
                add_response 158.39
              end

              # Q7
              should "ask 'are you provided with free accomodation'" do
                assert_current_node :is_provided_with_accommodation?
              end

              context "answer 'no' to 'are you provided with accomodation?'" do
                setup do
                  add_response :no
                end

                # Q8
                should "ask 'does your employer charge for things you need to do your job?'" do
                  assert_current_node :does_employer_charge_for_job_requirements?
                end

                context "answer no to 'charge for things you need to do your job'" do
                  setup do
                    add_response :no
                  end
                  # Q9
                  should "ask 'do you do additional work outside your shift'" do
                    assert_current_node :current_additional_work_outside_shift?
                  end

                  context "answer 'no'" do
                    setup do
                      add_response :no
                    end

                    should "show the results" do
                      assert_equal false, current_state.calculator.potential_underpayment?
                      assert_current_node :current_payment_below
                    end
                  end
                  context "answer 'yes'" do
                    setup do
                      add_response :yes
                    end

                    should "ask 'are you paid for additional work outside shift'" do
                      assert_current_node :current_paid_for_work_outside_shift?
                    end
                    context "answer yes" do
                      setup do
                        add_response :yes
                      end
                      should "show the results" do
                        assert_equal false, current_state.calculator.potential_underpayment?
                        assert_current_node :current_payment_below
                      end
                    end
                    context "answer no" do
                      setup do
                        add_response :no
                      end
                      should "show the results" do
                        # not paid for additional work = potential underpayment
                        assert_equal true, current_state.calculator.potential_underpayment?
                        assert_current_node :current_payment_below
                      end
                    end
                  end
                end

                context "answer yes to 'charge for things you need to do your job'" do
                  setup do
                    add_response :yes
                  end
                  # Q9
                  should "ask 'do you do additional work outside your shift'" do
                    assert_current_node :current_additional_work_outside_shift?
                  end

                  context "answer 'no'" do
                    setup do
                      add_response :no
                    end

                    should "show the results" do
                      # charged for things needed to do job = potential underpayment
                      assert_equal true, current_state.calculator.potential_underpayment?
                      assert_current_node :current_payment_below
                    end
                  end
                  context "answer 'yes'" do
                    setup do
                      add_response :yes
                    end

                    should "ask 'are you paid for additional work outside shift'" do
                      assert_current_node :current_paid_for_work_outside_shift?
                    end
                    context "answer yes" do
                      setup do
                        add_response :yes
                      end
                      should "show the results" do
                        # charged for things needed to do job = potential underpayment
                        assert_equal true, current_state.calculator.potential_underpayment?
                        assert_current_node :current_payment_below
                      end
                    end
                    context "answer no" do
                      setup do
                        add_response :no
                      end
                      should "show the results" do
                        # charged for things needed to do job = potential underpayment
                        assert_equal true, current_state.calculator.potential_underpayment?
                        assert_current_node :current_payment_below
                      end
                    end
                  end
                end
              end

              context "answer 'yes_free' to 'are you provided with accomodation?'" do
                setup do
                  add_response :yes_free
                end

                # Q7b
                should "ask 'how many days do you live in the accomodation?'" do
                  assert_current_node :current_accommodation_usage?
                end

                context "answer '1' day a week accomodation " do
                  setup do
                    add_response 1
                  end

                  # Q9
                  should "ask 'does_employer_charge_for_job_requirements?'" do
                    assert_current_node :does_employer_charge_for_job_requirements?
                  end

                  context "answer 'no' to 'does employer charge to job requirements'" do
                    setup do
                      add_response :no
                    end

                    should "ask 'do you work outside your shift?'" do
                      assert_current_node :current_additional_work_outside_shift?
                    end

                    context "answer 'no' to 'do you work outside your shift?'" do
                      setup do
                        add_response :no
                      end

                      should "show the results" do
                        assert_current_node :current_payment_below
                      end
                    end
                  end
                end
              end

              # Where accommodation is charged under the £4.73 threshold.
              # No adjustment is made to basic pay.
              context "answer 'yes_charged' to 'are you provided with accommodation?'" do
                setup do
                  add_response :yes_charged
                end

                # Q9
                should "ask 'how much are you charged?'" do
                  assert_current_node :current_accommodation_charge?
                end

                context "answer '8' to 'how much were you charged?'" do
                  setup do
                    add_response 8
                  end

                  should "ask 'how many days do you live in the accomodation?'" do
                    assert_current_node :current_accommodation_usage?
                  end

                  context "answer '1' day a week accomodation " do
                    setup do
                      add_response 1
                    end

                    # Q9
                    should "ask 'does_employer_charge_for_job_requirements?'" do
                      assert_current_node :does_employer_charge_for_job_requirements?
                    end

                    context "answer 'no' to 'does employer charge to job requirements'" do
                      setup do
                        add_response :no
                      end

                      should "ask 'do you work outside your shift?'" do
                        assert_current_node :current_additional_work_outside_shift?
                      end

                      context "answer 'no' to 'do you work outside your shift?'" do
                        setup do
                          add_response :no
                        end

                        should "show the results" do
                          assert_current_node :current_payment_below
                        end
                      end
                    end
                  end
                end
              end # Overtime hours
            end # Basic pay

            # Again with a better basic pay to achieve > min. wage.
            context "answer '300' to 'how much do you get paid?'" do
              setup do
                add_response 300
                add_response :no # no accommodation
                add_response :no # no job requirements charge
                add_response :no # no additional work
              end
              should "show above min. wage results" do
                assert_current_node :current_payment_above
              end
            end # Basic pay
          end # Basic hours
        end # Pay frequency
      end # Age
    end # Apprentice
  end # Current pay

  # Past payments
  #
  context "when checking past pay" do
    setup do
      add_response :past_payment
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
        assert_current_node :how_often_did_you_get_paid?
      end

      context "answered weekly to 'how often did you get paid?'" do
        setup do
          add_response "7"
        end

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
          should "succeed on 0.01 entered" do
            add_response "0.01"
          end
        end

        context "answered 'how many hours did you work?'" do
          setup do
            add_response 42
          end

          should "ask 'how much did you get paid?'" do
            assert_current_node :how_much_were_you_paid_during_pay_period?
          end

          context "answered 158.39 to 'how much did you get paid?'" do
            setup do
              add_response 158.39
            end

            should "ask 'were you provided with accommodation?'" do
              assert_current_node :was_provided_with_accommodation?
            end

            context "answer 'no' to 'were you provided with accommodation?'" do
              setup do
                add_response :no
              end

              should "ask 'did the employer charge for job requirements'" do
                assert_current_node :did_employer_charge_for_job_requirements?
              end
            end

            # Where accommodation is charged under the £4.73 threshold.
            # No adjustment is made to basic pay.
            #
            context "answer 'yes charged accommodation' to 'were you provided with accommodation?'" do
              setup do
                add_response :yes_charged
              end

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

                  should "ask 'did the employer charge for job requirements'" do
                    assert_current_node :did_employer_charge_for_job_requirements?
                  end

                  context "answer no to 'did the employer charge for job requirements?'" do
                    setup do
                      add_response :no
                    end

                    should "ask 'did you work hours outside your shift'" do
                      assert_current_node :past_additional_work_outside_shift?
                    end

                    context "answer no to 'did you work hours outside your shift?'" do
                      setup do
                        add_response :no
                      end

                      should "show results'" do
                        assert_current_node :past_payment_below
                      end
                      should "make outcome calculations" do
                        assert_equal 42, current_state.calculator.total_hours
                        assert_equal 4.15, current_state.calculator.minimum_hourly_rate
                        assert_equal false, current_state.calculator.minimum_wage_or_above?
                      end
                    end
                  end
                end
              end
            end
          end

          # Again with a better basic pay to achieve < min. wage.
          #
          context "answer '20' to 'how much did you get paid?'" do
            setup do
              add_response 20
              add_response :no # no accommodation
              add_response :no # no job requirement charge
              add_response :no # no additional work
            end

            should "show below min. wage results" do
              assert_current_node :past_payment_below
            end
          end
        end
      end
    end

    context "answered 'apprentice over 19' to 'were you an apprentice?'" do
      setup do
        add_response :apprentice_over_19
      end

      should "ask 'how often did you get paid?'" do
        assert_current_node :how_often_did_you_get_paid?
      end

      context "answered weekly to 'how often did you get paid?'" do
        setup do
          add_response "7"
        end

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
          should "succeed on 0.01 entered" do
            add_response "0.01"
          end
        end

        context "answered 'how many hours did you work?'" do
          setup do
            add_response 42
          end

          should "ask 'how much did you get paid?'" do
            assert_current_node :how_much_were_you_paid_during_pay_period?
          end

          context "answered 158.39 to 'how much did you get paid?'" do
            setup do
              add_response 158.39
            end

            should "ask 'were you provided with accommodation?'" do
              assert_current_node :was_provided_with_accommodation?
            end
          end

          # Again with a better basic pay to achieve < min. wage.
          #
          context "answer '20' to 'how much did you get paid?'" do
            setup do
              add_response 20
              add_response :no # no accommodation
              add_response :no # no job requirement charge
              add_response :no # no additional work
            end
            should "show below min. wage results" do
              assert_current_node :past_payment_below
            end
          end
        end
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
              should "ask 'were you provided with accommodation?'" do
                assert_current_node :was_provided_with_accommodation?
              end

              context "answer 'no' to 'were you provided with accommodation?'" do
                setup do
                  add_response :no
                end
                # Q8
                should "ask 'does your employer charge for things you need to do your job?'" do
                  assert_current_node :did_employer_charge_for_job_requirements?
                end

                context "answer no to 'charge for things you need to do your job'" do
                  setup do
                    add_response :no
                  end
                  # Q9
                  should "ask 'do you do additional work outside your shift'" do
                    assert_current_node :past_additional_work_outside_shift?
                  end

                  context "answer 'no'" do
                    setup do
                      add_response :no
                    end

                    should "show the results" do
                      # no additional work or charge for job requitements = no potential underpayment
                      assert_equal false, current_state.calculator.potential_underpayment?
                      assert_current_node :past_payment_below
                    end
                  end

                  context "answer 'yes'" do
                    setup do
                      add_response :yes
                    end

                    should "ask 'were you paid for additional work" do
                      assert_current_node :past_paid_for_work_outside_shift?
                    end

                    context "answer 'no'" do
                      setup do
                        add_response :no
                      end

                      should "show the results" do
                        # unpaid work outside shift = potential underpayment
                        assert_equal true, current_state.calculator.potential_underpayment?
                        assert_current_node :past_payment_below
                      end
                    end

                    context "answer 'yes'" do
                      setup do
                        add_response :yes
                      end

                      should "show the results" do
                        # paid for work outside shift = no potential underpayment
                        assert_equal false, current_state.calculator.potential_underpayment?
                        assert_current_node :past_payment_below
                      end
                    end
                  end
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

                    should "ask 'does your employer charge for things you need to do your job?'" do
                      assert_current_node :did_employer_charge_for_job_requirements?
                    end

                    context "answer no to 'charge for things you need to do your job'" do
                      setup do
                        add_response :no
                      end
                      # Q9
                      should "ask 'do you do additional work outside your shift'" do
                        assert_current_node :past_additional_work_outside_shift?
                      end

                      context "answer 'no'" do
                        setup do
                          add_response :no
                        end

                        should "show the results" do
                          assert_current_node :past_payment_below
                        end

                        should "make outcome calculations" do
                          assert_equal 42, current_state.calculator.total_hours
                          assert_equal 6.45, current_state.calculator.minimum_hourly_rate
                          assert_equal false, current_state.calculator.minimum_wage_or_above?
                        end
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
                add_response :no # no accommodation
                add_response :no # no job requirement charge
                add_response :no # no additional work
              end
              should "show above min. wage results" do
                assert_current_node :past_payment_below
              end
            end # Basic pay
          end # Basic hours
        end # Pay frequency
      end # Age
    end # Apprentice
  end

  context "2020 scenarios" do
    setup do
      travel_to(Date.parse("2020-04-01"))
      setup_for_testing_flow AmIGettingMinimumWageFlow
    end

    context "23 year old, 2nd year apprentice, paid additional work" do
      should "earn below minimum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "apprentice_over_19_second_year_onwards"

        assert_current_node :how_old_are_you?
        add_response "23"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "40"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "156"

        assert_current_node :is_provided_with_accommodation?
        add_response "no"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "yes"

        assert_current_node :current_paid_for_work_outside_shift?
        add_response "yes"

        assert_current_node :current_payment_below
        assert_equal 8.20, current_state.calculator.minimum_hourly_rate
      end
    end

    context "20 year old, second year apprentice, charged for job requirements" do
      should "earn below minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "apprentice_over_19_second_year_onwards"

        assert_current_node :how_old_are_you?
        add_response "20"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "38"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "200"

        assert_current_node :is_provided_with_accommodation?
        add_response "no"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "yes"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_below
        assert_equal 6.45, current_state.calculator.minimum_hourly_rate
      end
    end

    context "when user is earning below minimum wage, with accomodation" do
      should "adjust underpayment based on the current rate" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "30"

        assert_current_node :how_often_do_you_get_paid?
        add_response "21"

        assert_current_node :how_many_hours_do_you_work?
        add_response "120"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "988.80"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_charged"

        assert_current_node :current_accommodation_charge?
        add_response 7.80

        assert_current_node :current_accommodation_usage?
        add_response 7

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_below
        assert_equal 8.72, current_state.calculator.minimum_hourly_rate
        # 7.80 accomodation * 21 days = £163.80
        # £7.55 (offset rate used when accommodation is free) * 21 = £158.55
        # #988.80 pay - £163.80 accomodation + £158.55 offset = £938.55
        # £983.55 / 120 (total hours in pay period) = £8.20 an hour
      end
    end

    context "Over 25 years old, not an apprentice, free accomodation" do
      should "earn above minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "30"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "30"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "210"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_free"

        assert_current_node :current_accommodation_usage?
        add_response 7

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "yes"

        assert_current_node :current_paid_for_work_outside_shift?
        add_response "yes"

        assert_current_node :current_payment_above
        assert_equal 8.72, current_state.calculator.minimum_hourly_rate
        # £210/30 = £7 an hour
        # £7.55 (offset rate used when accommodation is free) * 7 = £52.85
        # £52.85 + 210 = £262.85
        # £262.85 / 30 (total hours in pay period) = £8.76
      end
    end

    context "22 years old, not an apprentice, charged accomodation but below offset" do
      should "earn above minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "22"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "41"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "320"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_charged"

        assert_current_node :current_accommodation_charge?
        add_response 3.50

        assert_current_node :current_accommodation_usage?
        add_response 7

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_below
        assert_equal 8.20, current_state.calculator.minimum_hourly_rate
        # £320/41 = £7.80 an hour
        # £3.50 accomodation chage below £7.55 offset
      end
    end

    context "18 years old, first year apprentice, paid extra working time" do
      should "earn above minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "apprentice_under_19"

        assert_current_node :how_often_do_you_get_paid?
        add_response "14"

        assert_current_node :how_many_hours_do_you_work?
        add_response "70"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "273"

        assert_current_node :is_provided_with_accommodation?
        add_response "no"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "yes"

        assert_current_node :current_paid_for_work_outside_shift?
        add_response "yes"

        assert_current_node :current_payment_below
        assert_equal 4.15, current_state.calculator.minimum_hourly_rate
      end
    end
    context "18 years old, first year apprentice" do
      should "earn above minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "apprentice_under_19"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "20"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "205"

        assert_current_node :is_provided_with_accommodation?
        add_response "no"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_above
        assert_equal 4.15, current_state.calculator.minimum_hourly_rate
      end
    end
    context "25 years old, not an apprentice, charged accomodation, paid working time" do
      should "earn above minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "25"

        assert_current_node :how_often_do_you_get_paid?
        add_response "5"

        assert_current_node :how_many_hours_do_you_work?
        add_response "25"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "70"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_charged"

        assert_current_node :current_accommodation_charge?
        add_response 3.50

        assert_current_node :current_accommodation_usage?
        add_response 7

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "yes"

        assert_current_node :current_paid_for_work_outside_shift?
        add_response "yes"

        assert_current_node :current_payment_below
        assert_equal 8.72, current_state.calculator.minimum_hourly_rate
      end
    end
    context "26 years old, not an apprentice, paid extra working time" do
      should "earn above minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "26"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "205"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_charged"

        assert_current_node :current_accommodation_charge?
        add_response 1

        assert_current_node :current_accommodation_usage?
        add_response 7

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "yes"

        assert_current_node :current_paid_for_work_outside_shift?
        add_response "yes"

        assert_current_node :current_payment_above
        assert_equal 8.72, current_state.calculator.minimum_hourly_rate
      end
    end
    context "35 years old, not an apprentice, charged accomodation" do
      should "earn above minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "35"

        assert_current_node :how_often_do_you_get_paid?
        add_response "21"

        assert_current_node :how_many_hours_do_you_work?
        add_response "120"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "988.80"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_charged"

        assert_current_node :current_accommodation_charge?
        add_response "7.80"

        assert_current_node :current_accommodation_usage?
        add_response 7

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_below
        assert_equal 8.72, current_state.calculator.minimum_hourly_rate
      end
    end
  end

  context "2021 scenarios" do
    setup do
      travel_to(Date.parse("2021-04-01"))
      setup_for_testing_flow AmIGettingMinimumWageFlow
    end

    context "27 year old, not apprentice, no additional charges" do
      should "earn above minimum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "past_payment"

        assert_current_node :were_you_an_apprentice?
        add_response "no"

        assert_current_node :how_old_were_you?
        add_response "27"

        assert_current_node :how_often_did_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_did_you_work?
        add_response "37"

        assert_current_node :how_much_were_you_paid_during_pay_period?
        add_response "325"

        assert_current_node :was_provided_with_accommodation?
        add_response "no"

        assert_current_node :did_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :past_additional_work_outside_shift?
        add_response "no"

        assert_equal 8.72, current_state.calculator.minimum_hourly_rate
        assert_current_node :past_payment_above
      end
    end

    context "under 19 apprentice, is an apprentice" do
      should "earn below minimum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "apprentice_under_19"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "42.99"

        assert_current_node :is_provided_with_accommodation?
        add_response "no"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_below
        # hourly rate is the same due to rounding but overall pay is below
        assert_equal 4.30, current_state.calculator.minimum_hourly_rate
      end
    end

    context "under 19 apprentice, free accommodation" do
      should "earn below minimum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "apprentice_under_19"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "34.46"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_free"

        assert_current_node :current_accommodation_usage?
        add_response "1"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_below
        assert_equal 4.30, current_state.calculator.minimum_hourly_rate
        # £8.36 (offset rate used when accommodation is free) * 1 = £8.36
        # £34.46 (total pay) + £8.36 / 10 = £4.282
      end
    end

    context "under 19 apprentice, is an apprentice" do
      should "earn above minimum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "apprentice_under_19"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "43.0"

        assert_current_node :is_provided_with_accommodation?
        add_response "no"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_above
        assert_equal 4.30, current_state.calculator.minimum_hourly_rate
      end
    end

    context "16 year old, not an apprentice" do
      should "earn below minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "16"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "46.19"

        assert_current_node :is_provided_with_accommodation?
        add_response "no"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_below
        # hourly rate is the same due to rounding but overall pay is below
        assert_equal 4.62, current_state.calculator.minimum_hourly_rate
      end
    end

    context "16 year old, not an apprentice, free accommodation" do
      should "earn above minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "16"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "37.84"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_free"

        assert_current_node :current_accommodation_usage?
        add_response "1"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_above
        assert_equal 4.62, current_state.calculator.minimum_hourly_rate
      end
    end

    context "16 year old, not an apprentice, charged accommodation" do
      should "earn below minimum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "16"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "46.19"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_charged"

        assert_current_node :current_accommodation_charge?
        add_response "8.0"

        assert_current_node :current_accommodation_usage?
        add_response "1"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_above
        # hourly rate is the same due to rounding but overall pay is below
        # £8.0 accommodation charge is below £8.36 offset
        assert_equal 4.62, current_state.calculator.minimum_hourly_rate
      end
    end

    context "16 year old, not an apprentice, charged accommodation" do
      should "earn below minimum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "16"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "46.20"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_charged"

        assert_current_node :current_accommodation_charge?
        add_response "9.0"

        assert_current_node :current_accommodation_usage?
        add_response "1"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_below
        # hourly rate is the same due to rounding but overall pay is below
        # £46.20 (total pay) - £9.0 (accommodation charge) + £8.36 (offset) / 10 (days worked) = £4.556
        assert_equal 4.62, current_state.calculator.minimum_hourly_rate
      end
    end

    context "19 year old, not an apprentice" do
      should "earn above minimum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "19"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "65.69"

        assert_current_node :is_provided_with_accommodation?
        add_response "no"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_above
        assert_equal 6.56, current_state.calculator.minimum_hourly_rate
      end
    end

    context "21 year old, not an apprentice, free accommodation" do
      should "earn below minimum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "21"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "75.23"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_free"

        assert_current_node :current_accommodation_usage?
        add_response "1"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_below
        # hourly rate is the same due to rounding but overall pay is below
        # £8.36 (offset rate used when accommodation is free) * 1 = £8.36
        # £75.23 (total pay) + £8.36 / 10 = £8.359
        assert_equal 8.36, current_state.calculator.minimum_hourly_rate
      end
    end

    context "23 year old, not an apprentice, charged for accommodation and job requirements" do
      should "earn above minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "not_an_apprentice"

        assert_current_node :how_old_are_you?
        add_response "23"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "89.10"

        assert_current_node :is_provided_with_accommodation?
        add_response "yes_charged"

        assert_current_node :current_accommodation_charge?
        add_response "7.80"

        assert_current_node :current_accommodation_usage?
        add_response "1"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "yes"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_above
        # £7.80 accommodation charge is below £8.36 offset
        assert_equal 8.91, current_state.calculator.minimum_hourly_rate
      end
    end

    context "over 19 year old apprentice in first year" do
      should "earn below minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "apprentice_over_19_first_year"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "42.99"

        assert_current_node :is_provided_with_accommodation?
        add_response "no"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_below
        # hourly rate is the same due to rounding but overall pay is below
        assert_equal 4.30, current_state.calculator.minimum_hourly_rate
      end
    end

    context "27 year old apprentice in second year" do
      should "earn below minmum wage" do
        assert_current_node :what_would_you_like_to_check?
        add_response "current_payment"

        assert_current_node :are_you_an_apprentice?
        add_response "apprentice_over_19_second_year_onwards"

        assert_current_node :how_old_are_you?
        add_response "27"

        assert_current_node :how_often_do_you_get_paid?
        add_response "7"

        assert_current_node :how_many_hours_do_you_work?
        add_response "10"

        assert_current_node :how_much_are_you_paid_during_pay_period?
        add_response "79.10"

        assert_current_node :is_provided_with_accommodation?
        add_response "no"

        assert_current_node :does_employer_charge_for_job_requirements?
        add_response "no"

        assert_current_node :current_additional_work_outside_shift?
        add_response "no"

        assert_current_node :current_payment_below
        assert_equal 8.91, current_state.calculator.minimum_hourly_rate
      end
    end
  end
end
