require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/state-pension-age"

class StatePensionAgeTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::StatePensionAgeFlow
  end

  should "ask which calculation to perform" do
    assert_current_node :which_calculation?
  end

  # #Age
  context "age calculation" do
    setup do
      add_response :age
    end

    should "ask your gender" do
      assert_current_node :gender?
    end

    context "male" do
      setup do
        add_response :male
      end

      should "ask for date of birth" do
        assert_current_node :dob_age?
      end

      should "prevent from providing future dates" do
        add_response (Date.today + 1).to_s
        assert_current_node_is_error
      end

      should "prevent from providing dates too far in the past" do
        add_response (200.years.ago).to_s
        assert_current_node_is_error
      end

      context "pension_credit_date check -- born 5th Dec 1953" do
        setup { add_response Date.parse("5th Dec 1953")}
        should "go to age result" do
          assert_current_node :age_result
          assert_state_variable :state_pension_date, Date.parse("05 Dec 2018")
          assert_state_variable :pension_credit_date, Date.parse("06 Nov 2018").strftime("%-d %B %Y")
        end
      end

      context "age is less than 20 years" do
        should "user is too young to get more information" do
          add_response Date.today.advance(years: -15)

          assert_current_node :too_young
        end
      end

      context "age is between 4 months and 1 day from SP age" do
        setup do
          Timecop.travel("2013-07-15")
        end

        should "state that user is near state pension age when born on 16th July 1948" do
          add_response Date.parse("16 July 1948") # retires 16 July 2013
          assert_current_node :near_state_pension_age
        end

        should "state that user is near state pension age when born on 14th November 1948" do
          add_response Date.parse("14 November 1948") # retires 14 Nov 2013
          assert_current_node :near_state_pension_age
        end
      end

      context "born on 6th April 1945" do
        setup do
          add_response Date.parse("6th April 1945")
        end

        should "give an answer" do
          assert_current_node :age_result
          assert_state_variable "state_pension_age", "65 years"
          assert_state_variable "formatted_state_pension_date", "6 April 2010"
        end
      end # born on 6th of April

      context "born on 5th November 1948" do
        setup do
          Timecop.travel("2013-07-22")
          add_response Date.parse("1948-11-05")
        end

        should "be near to the state pension age" do
          assert_state_variable :available_ni_years, 45
          assert_current_node :near_state_pension_age
        end
      end

      context "two days ahead of date in July 2013" do
        setup do
          Timecop.travel("2013-07-24")
          add_response Date.parse("1948-07-26")
        end

        should "tell the user that they're near state pension age" do
          assert_current_node :near_state_pension_age
        end
      end
    end # male

    context "female, born on 4 August 1951" do
      setup do
        Timecop.travel('2012-10-08')
        add_response :female
        add_response Date.parse("4th August 1951")
      end

      should "tell them they are within four months and one day of state pension age" do
        assert_current_node :near_state_pension_age
        assert_state_variable "formatted_state_pension_date", "6 November 2012"
      end
    end

    context "female born on 1 July 1956, timecop day before near_state_pension_age" do
      setup do
        Timecop.travel('2014-05-06')
        add_response :female
        add_response Date.parse('1 July 1952')
      end

      should "show result for state_pension_age_is outcome" do
        assert_current_node :age_result
      end
    end

    context "additional coverage for birthdate 6 March 1961" do
      setup do
        Timecop.travel('2014-05-07')
      end
      should "go to correct outcome" do
        add_response :male
        add_response Date.parse('6 March 1961')
        assert_current_node :age_result
      end
    end

    context "male with different state pension and pension credit dates" do
      setup do
        Timecop.travel('2014-05-07')
      end
      should "go to correct outcome with pension_credit_past" do
        add_response :male
        add_response Date.parse('3 February 1952')
        assert_current_node :age_result
        assert_state_variable :formatted_state_pension_date, '3 February 2017'
        assert_state_variable :pension_credit_date, '6 November 2013'
      end
    end

    context "test correct state pension age" do
      setup do
        Timecop.travel('2014-05-08')
      end
      should "show state pension age of 60 years" do
        add_response :female
        add_response Date.parse('23 April 1949')
        assert_current_node :age_result
        assert_state_variable :state_pension_age, "60 years"
      end

      should "show state pension age of 65 years" do
        add_response :male
        add_response Date.parse('23 April 1951')
        assert_current_node :age_result
        assert_state_variable :state_pension_age, "65 years"
      end

      should "show state pension age of 66 years" do
        add_response :male
        add_response Date.parse('23 October 1954')
        assert_current_node :age_result
        assert_state_variable :state_pension_age, "66 years"
      end

      should "show state pension age of 66 years, 1 month" do
        add_response :male
        add_response Date.parse('23 April 1960')
        assert_current_node :age_result
        assert_state_variable :state_pension_age, "66 years, 1 month"
      end

      should "show state pension age of 66 years, 10 month" do
        add_response :male
        add_response Date.parse('23 January 1961')
        assert_current_node :age_result
        assert_state_variable :state_pension_age, "66 years, 10 months"
      end

      should "show state pension age of 67" do
        add_response :male
        add_response Date.parse('23 March 1969')
        assert_current_node :age_result
        assert_state_variable :state_pension_age, "67 years"
      end

      should "show state pension age of 68" do
        add_response :male
        add_response Date.parse('23 March 1978')
        assert_current_node :age_result
        assert_state_variable :state_pension_age, "67 years, 11 months, 11 days"
      end

      should "should show 67 years old as state pension age" do
        add_response :female
        add_response Date.parse('1968-04-07')
        assert_current_node :age_result
        assert_state_variable :state_pension_age, "67 years"
      end

      should "should also show 67 years old" do
        add_response :male
        add_response Date.parse('1969-03-07')
        assert_current_node :age_result
        assert_state_variable :state_pension_age, "67 years"
      end

      should "show the correct number of days for people born on 29th February" do
        add_response :female
        add_response Date.parse('29 February 1952')
        assert_current_node :age_result
        assert_state_variable :state_pension_age, '61 years, 10 months, 7 days'
      end
    end
  end # age calculation

  #Amount
  #
  context "amount calculation" do
    setup do
      add_response :amount
    end

    should "ask your gender" do
      assert_current_node :gender?
    end

    context "male" do
      setup {add_response :male}

      should "ask for date of birth" do
        assert_current_node :dob_amount?
      end

      context "between 7 and 10 years NI including credits \
               born within automatic NI age group (1959-04-06 - 1992-04-05)" do
        setup do
          add_response Date.parse('1971-08-02')
          add_response 8
          add_response 0
          add_response :no
        end

        should "take me to Amount Result without asking Have you lived or worked outside the UK?" do
          assert_current_node :amount_result
        end
      end

      context 'Born after 1992-04-05' do
        context "more than 10 years NI contributions" do
          setup do
            Timecop.travel('2030-04-06')
            add_response Date.parse('1999-04-06')
            add_response 11
            add_response 0
            add_response :no
          end

          should "take me to years of work" do
            assert_current_node :years_of_work?
          end
        end

        context "less than 10 years NI contributions" do
          setup do
            add_response Date.parse('1992-04-06')
            add_response 0
            add_response 0
            add_response :no
          end

          should "take me to lived years of work" do
            assert_current_node :years_of_work?
          end
        end
      end

      context "give a date in the future" do
        should "raise an error" do
          add_response (Date.today + 1).to_s
          assert_current_node_is_error
        end
      end

      context "within four months and one day of state pension age test" do
        setup do
          Timecop.travel('2012-10-08')
          add_response Date.parse('1948-02-09')
        end

        should "ask for how many years National Insurance has been paid" do
          assert_current_node :years_paid_ni?
        end
      end

      context "born 28th July 2013 and running on 25th July 2013" do
        setup do
          Timecop.travel("2013-07-25")
          add_response Date.parse("1948-07-28")
        end

        should "ask for how many years National Insurance has been paid" do
          assert_current_node :years_paid_ni?
        end
      end

      context "four months and five days from state pension age test" do
        setup do
          Timecop.travel('2012-10-08')
          add_response Date.parse('1948-02-13')
        end

        should "ask for years paid ni" do
          assert_state_variable :ni_years_to_date_from_dob, 45
          assert_current_node :years_paid_ni?
        end
      end

      context "older than 20 years from state pension date" do
        setup do
          Timecop.travel('2012-10-08')
          add_response Date.parse('1968-02-13')
        end

        should "ask for years paid ni" do
          assert_state_variable :ni_years_to_date_from_dob, 25
          assert_current_node :years_paid_ni?
        end
      end

      context "is state pension age" do
        setup do
          Timecop.travel("2013-07-18")
          add_response Date.parse("1948-07-18")
        end

        should "should show the result and have the state pension age assigned" do
          assert_state_variable :state_pension_age, "65 years"
          assert_current_node :reached_state_pension_age
        end
      end
    end # male

    context "female" do
      setup do
        Timecop.travel('2014-05-06')
        add_response :female
      end

      should "ask for date of birth" do
        assert_current_node :dob_amount?
      end

      context "under 20 years old" do
        should "say not enough qualifying years" do
          add_response 5.years.ago
          assert_current_node :too_young
        end
      end

      context "90 years old" do
        should "say already reached state pension age" do
          add_response 90.years.ago
          assert_current_node :reached_state_pension_age
        end
      end

      context "50 years old" do
        setup do
          Timecop.travel('2012-10-08')
          add_response Date.civil(50.years.ago.year, 4, 7)
        end

        should "ask for number of years paid NI" do
          assert_state_variable :remaining_years, 17
          assert_state_variable :ni_years_to_date_from_dob, 31
          assert_current_node :years_paid_ni?
        end

        context "30 years of NI" do
          should "show the result" do
            add_response 30
            add_response 0 # unemployment
            add_response 'no' # claimed benefits
            assert_current_node :amount_result
          end
        end

        context "27 years of NI" do
          setup do
            add_response 37
          end

          should "return error as they will only have available_ni_years of 21" do
            assert_current_node_is_error
          end
        end

        context "10 years of NI" do
          setup do
            add_response 10
          end

          should "ask for number of years claimed JSA" do
            assert_state_variable "available_ni_years", 21
            assert_current_node :years_of_jsa?
          end

          context "7 years of jsa" do
            should "show the result" do
              add_response 7
              assert_state_variable "available_ni_years", 14
              assert_current_node :received_child_benefit?
            end
          end

          context "1 year of jsa" do
            setup do
              add_response 1
            end

            should "ask for years of benefit" do
              assert_current_node :received_child_benefit?
            end
          end
        end
      end

      context "born between 1959-04-06 or 1992-04-05, not enough qualifying years, no child benefit" do
        setup do
          Timecop.travel('2014-05-06')
        end
        should "return amount_result" do
          add_response Date.parse("8th October 1960")
          add_response :yes
          add_response 25   # ni years
          add_response 1    # jsa years
          add_response :no
          assert_current_node :amount_result
        end
      end

      context "(testing from years_of_benefit) age 40, NI = 5, JSA = 5, cb = yes " do
        setup do
          Timecop.travel('2014-05-06')
          add_response Date.civil(40.years.ago.year, 4, 7)
          add_response 10
          add_response 5
          add_response :yes
        end

        should "error when entering more than 6 (over available_ni_years limit)"  do
          add_response 7
          assert_current_node_is_error
        end

        should "pass when entering 6 (go to amount_result as available_ni_years is maxed)" do
          add_response 6
          assert_current_node :amount_result
        end

        context "answer 0" do
          setup {add_response 0}

          should "be at years_of_caring?" do
            assert_state_variable "available_ni_years", 6
            assert_current_node :years_of_caring?
          end

          should "fail on 5" do
            add_response 5
            assert_current_node_is_error
          end

          should "pass when entering 4" do
            add_response 4
            add_response 2
            assert_current_node :amount_result
          end

          context "answer 0" do
            setup {add_response 0}

            should "go to years_of_carers_allowance" do
              assert_state_variable "available_ni_years", 6
              assert_current_node :years_of_carers_allowance?
            end

            should "fail on 17" do
              add_response 17
              assert_current_node_is_error
            end

            should "pass when entering 1 (go to amount_result as available_ni_years is maxed)" do
              add_response 1
              assert_current_node :amount_result
            end

            context "answer 0" do
              setup {add_response 0}

              should "got to years_of_work?" do
                assert_state_variable "available_ni_years", 6
                assert_current_node :amount_result
              end
            end
          end
        end
      end

      context "answer born Jan 1st 1970" do
        setup do
          Timecop.travel('2014-05-06')
          add_response Date.parse('1970-01-01')
          add_response 20
          add_response 0
          add_response :no
        end

        should "add 3 years credit for a person born between 1959 and 1992" do
          assert_current_node :amount_result
          assert_state_variable "missing_years", 7
        end
      end

      context "years_you_can_enter test" do
        setup do
          add_response Date.civil(49.years.ago.year, 4, 7)
          add_response 20
          add_response 5
          add_response :yes
        end

        should "return 5" do
          assert_state_variable "available_ni_years", 5
          assert_state_variable "years_you_can_enter", 5
          assert_current_node :years_of_benefit?
        end
      end

      context "starting credits test 2" do
        setup do
          Timecop.travel('2014-05-06')
          add_response Date.parse('1964-12-06')
          add_response 27
          add_response 3 # unemployment, sickeness
        end

        should "add starting credits and go to results" do
          assert_state_variable :qualifying_years_total, 33
          assert_current_node :amount_result
        end
      end

      context "born before 1962-01-01" do
        setup do
          add_response Date.parse('1961-01-01')
          add_response :no
          add_response 2
        end

        should "tell not to count years before 2010 with reduced NI rate" do
          assert_current_node :years_of_jsa?
          assert_state_variable :carer_hint_for_women_before_1962, "Don’t count years before April 2010 when you opted for the reduced National Insurance rate for married women and widows."
        end
      end
    end # female

    context "within 4 months and 1 day of SPA, has enough qualifying years" do
      setup do
        Timecop.travel('2013-06-26')
        add_response 'male'
        add_response Date.parse('1948-08-09')
        add_response 30
      end
      should "display close to SPA outcome" do
        assert_current_node :amount_result
        assert_state_variable :qualifying_years_total, 30
        assert_state_variable "state_pension_age", "65 years"
        assert_state_variable "formatted_state_pension_date", " 9 August 2013"
      end
    end

    context "within 35 days of SPA, has enough qualifying years" do
      setup do
        Timecop.travel('2013-07-05')
        add_response 'male'
        add_response Date.parse('1948-08-09')
        add_response 30
      end
      should "display close to SPA outcome without pension statement" do
        assert_current_node :amount_result
        assert_state_variable :qualifying_years_total, 30
        assert_state_variable "state_pension_age", "65 years"
        assert_state_variable "formatted_state_pension_date", " 9 August 2013"
      end
    end

    context "within 4 months and 1 day of SPA, doesn't have enough qualifying years" do
      setup do
        Timecop.travel('2013-06-26')
        add_response 'male'
        add_response Date.parse('1948-08-09')
        add_response 20
        add_response 3
        add_response 'no'
        add_response 0
      end
      should "display close to SPA outcome" do
        assert_current_node :amount_result
        assert_state_variable :qualifying_years_total, 23
        assert_state_variable "state_pension_age", "65 years"
        assert_state_variable "formatted_state_pension_date", " 9 August 2013"
      end
    end

    context "within 35 days of SPA, doesn't have enough qualifying years" do
      setup do
        Timecop.travel('2013-07-05')
        add_response 'male'
        add_response Date.parse('1948-08-09')
        add_response 20
        add_response 3
        add_response 'no'
        add_response 0
      end
      should "display close to SPA outcome without pension statement" do
        assert_current_node :amount_result
        assert_state_variable :qualifying_years_total, 23
        assert_state_variable "state_pension_age", "65 years"
        assert_state_variable "formatted_state_pension_date", " 9 August 2013"
      end
    end

    context "people one day away from state pension with different birthdays" do
      # The following tests use values from factchecks around 5/9/13
      setup do
        Timecop.travel('5 Sep 2013')
        add_response 'female'
      end
      should "should show the correct result" do
        add_response Date.parse('4 Jan 1952')
        add_response 25
        add_response 5

        assert_state_variable "formatted_state_pension_date", " 6 September 2013"
        assert_current_node :amount_result
      end

      should "should show the correct result with pay_reduced_ni_rate" do
        add_response Date.parse('6 Dec 1951')
        add_response 10
        add_response 15
        add_response 'yes'
        add_response 2
        add_response 3

        assert_state_variable "formatted_state_pension_date", " 6 September 2013"
        assert_current_node :amount_result
      end

      context "for someone who has reached state pension age" do
        should "display the correct result" do
          add_response Date.parse('15 July 1945')

          assert_current_node :reached_state_pension_age
        end
      end
    end

    context "Non automatic ni group (with child benefit) and born on 29th of February (dynami date group)" do
      setup do
        add_response :female
        add_response Date.parse('29 February 1964')
        add_response 0
        add_response 0
        add_response :yes
        add_response 0
        add_response 0
        add_response 0
      end
      should "ask if worked abroad" do
        assert_current_node :lived_or_worked_outside_uk?
        assert_state_variable :state_pension_date, Date.parse("01 Mar 2031")
      end
    end
    context "Check state pension age date if born on 29th of february (static date group)" do
      setup do
        add_response :female
        add_response Date.parse('29 February 1952')
      end
      should "show pension age reached outcome with correct pension age date" do
        assert_current_node :reached_state_pension_age
        assert_state_variable :state_pension_date, Date.parse("06 Jan 2014")
        assert_state_variable :dob, Date.parse("1952-02-29")
      end
    end

    context "Over the age of 55 and getting new state pension" do
      setup do
        Timecop.travel("2015-01-01")
        add_response :male
        add_response Date.parse('1 January 1959')
      end

      should "show the over_55 result" do
        assert_current_node :over55_result
      end
    end
  end

  context "bus pass age" do
    setup do
      add_response :bus_pass
    end

    should "lead to bus_pass_age_result" do
      assert_current_node :dob_bus_pass?
      add_response '1956-05-31'
      assert_current_node :bus_pass_age_result
      assert_state_variable :qualifies_for_bus_pass_on, "31 May 2022"
    end
  end
end
