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
        setup {add_response 15}

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
          assert_equal 45, current_state.calculator.total_hours
          assert_equal 6.50, current_state.calculator.minimum_hourly_rate
          assert_equal 6.12, current_state.calculator.total_hourly_rate
          assert_equal false, current_state.calculator.minimum_wage_or_above?
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
          assert_equal 6.31, current_state.calculator.minimum_hourly_rate
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
          assert_equal 6.50, current_state.calculator.minimum_hourly_rate
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
          assert_equal 45, current_state.calculator.total_hours
          # NOTE: these are date sensitive vars - will be tested in the calculator tests
          # assert_state_variable "minimum_hourly_rate", 6.08 #
          # assert_state_variable "total_hourly_rate", "10.74" # time sensitive
          assert_equal true, current_state.calculator.minimum_wage_or_above?
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
                          assert_equal 42, current_state.calculator.total_hours
                          assert_equal 4.83, current_state.calculator.minimum_hourly_rate
                          assert_equal 3.75, current_state.calculator.total_hourly_rate
                          assert_equal false, current_state.calculator.minimum_wage_or_above?
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
          assert_equal 210, current_state.calculator.total_hours
          assert_equal 3.53, current_state.calculator.minimum_hourly_rate
          assert_equal 4.46, current_state.calculator.total_hourly_rate
          assert_equal true, current_state.calculator.minimum_wage_or_above?
          assert_equal 0, current_state.calculator.historical_adjustment
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
          assert_equal 210, current_state.calculator.total_hours
          assert_equal 3.53, current_state.calculator.minimum_hourly_rate
          assert_equal 3.21, current_state.calculator.total_hourly_rate
          assert_equal false, current_state.calculator.minimum_wage_or_above?
          assert_equal 70.38, current_state.calculator.historical_adjustment
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
      assert_equal 6.08, current_state.calculator.minimum_hourly_rate # rate on '2011-10-01'

      expected_underpayment = 46.18
      # (hours worked * hourly rate back then - paid by employer) / minimum hourly rate back then * minimum hourly rate today
      # (40h * £6.08 - £200.0) / 6.08 * 6.50 = 46.18
      assert_equal expected_underpayment, current_state.calculator.historical_adjustment
    end
  end

  context 'validation' do
    [
      :how_old_are_you?,
      :how_old_were_you?
    ].each do |age_question_name|
      context "for #{age_question_name}" do
        setup do
          @question = @flow.questions.find { |question| question.name == age_question_name }
          @state = SmartAnswer::State.new(@question)
          @calculator = stub('calculator',
            :age= => nil
          )
          @state.calculator = @calculator
        end

        should 'raise if the calculator says the age is invalid' do
          invalid_age = 0
          @calculator.stubs(:valid_age?).with(invalid_age).returns(false)
          assert_raise(SmartAnswer::InvalidResponse) do
            @question.transition(@state, invalid_age)
          end
        end

        should 'not raise if the calculator says the age is valid' do
          valid_age = 50
          @calculator.stubs(:valid_age?).with(valid_age).returns(true)
          assert_nothing_raised do
            @question.transition(@state, valid_age)
          end
        end
      end
    end

    [
      :how_often_do_you_get_paid?,
      :how_often_did_you_get_paid?
    ].each do |pay_frequency_question_name|
      context "for #{pay_frequency_question_name}" do
        setup do
          @question = @flow.questions.find { |question| question.name == pay_frequency_question_name }
          @state = SmartAnswer::State.new(@question)
          @calculator = stub('calculator',
            :pay_frequency= => nil
          )
          @state.calculator = @calculator
        end

        should 'raise if the calculator says the pay_frequency is invalid' do
          invalid_pay_frequency = 3
          @calculator.stubs(:valid_pay_frequency?).with(invalid_pay_frequency).returns(false)
          assert_raise(SmartAnswer::InvalidResponse) do
            @question.transition(@state, invalid_pay_frequency)
          end
        end

        should 'not raise if the calculator says the pay_frequency is valid' do
          valid_pay_frequency = 4
          @calculator.stubs(:valid_pay_frequency?).with(valid_pay_frequency).returns(true)
          assert_nothing_raised do
            @question.transition(@state, valid_pay_frequency)
          end
        end
      end
    end

    [
      :how_many_hours_do_you_work?,
      :how_many_hours_did_you_work?
    ].each do |hours_question_name|
      context "for #{hours_question_name}" do
        setup do
          @question = @flow.questions.find { |question| question.name == hours_question_name }
          @state = SmartAnswer::State.new(@question)
          @calculator = stub('calculator',
            pay_frequency: 1,
            :basic_hours= => nil
          )
          @state.calculator = @calculator
        end

        should 'use the error_hours error message' do
          @calculator.stubs(:valid_hours_worked?).returns(false)
          exception = assert_raise(SmartAnswer::InvalidResponse) do
            @question.transition(@state, '0')
          end
          assert_equal 'error_hours', exception.message
        end

        should 'raise if the calculator says the hours_worked is invalid' do
          invalid_hours_worked = 3
          @calculator.stubs(:valid_hours_worked?).with(invalid_hours_worked).returns(false)

          assert_raise(SmartAnswer::InvalidResponse) do
            @question.transition(@state, invalid_hours_worked)
          end
        end

        should 'not raise if the calculator says the hours_worked is valid' do
          valid_hours_worked = 4
          @calculator.stubs(:valid_hours_worked?).with(valid_hours_worked).returns(true)

          assert_nothing_raised do
            @question.transition(@state, valid_hours_worked)
          end
        end
      end
    end

    [
      :how_many_hours_overtime_do_you_work?,
      :how_many_hours_overtime_did_you_work?
    ].each do |overtime_hours_question_name|
      context "for #{overtime_hours_question_name}" do
        setup do
          @question = @flow.questions.find { |question| question.name == overtime_hours_question_name }
          @state = SmartAnswer::State.new(@question)
          @state.calculator = stub('calculator', :overtime_hours= => nil)
        end

        should 'not accept amount less than 0' do
          assert_raise(SmartAnswer::InvalidResponse) do
            @question.transition(@state, '-1')
          end
        end

        should 'accept 0 or more' do
          assert_nothing_raised do
            @question.transition(@state, '0')
          end
        end
      end
    end

    [
      :current_accommodation_charge?,
      :past_accommodation_charge?
    ].each do |accommodation_charge_question_name|
      context "for #{accommodation_charge_question_name}" do
        setup do
          @question = @flow.questions.find { |question| question.name == accommodation_charge_question_name }
          @state = SmartAnswer::State.new(@question)
        end

        should 'not accept amount less than or equal to 0' do
          assert_raise(SmartAnswer::InvalidResponse) do
            @question.transition(@state, '0')
          end
        end

        should 'accept 1 or more' do
          assert_nothing_raised do
            @question.transition(@state, '1')
          end
        end
      end
    end

    [
      :current_accommodation_usage?,
      :past_accommodation_usage?
    ].each do |accommodation_usage_question_name|
      context "for #{accommodation_usage_question_name}" do
        setup do
          @question = @flow.questions.find { |question| question.name == accommodation_usage_question_name }
          @state = SmartAnswer::State.new(@question)
          calculator = stub('calculator',
            accommodation_adjustment: nil,
            minimum_wage_or_above?: nil,
            historical_adjustment: 0
          )
          @state.calculator = calculator
        end

        should 'not accept days per week of less than or equal to -1' do
          assert_raise(SmartAnswer::InvalidResponse) do
            @question.transition(@state, '-1')
          end
        end

        should 'not accept days per week of greater than or equal to 8' do
          assert_raise(SmartAnswer::InvalidResponse) do
            @question.transition(@state, '8')
          end
        end

        should 'accept days per week greater than or equal to 0' do
          assert_nothing_raised do
            @question.transition(@state, '0')
          end
        end

        should 'accept days per week less than or equal to 7' do
          assert_nothing_raised do
            @question.transition(@state, '7')
          end
        end
      end
    end
  end
end
