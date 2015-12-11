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
  end # bus pass age
end
