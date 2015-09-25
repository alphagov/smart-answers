require_relative '../../test_helper'

require 'smart_answer_flows/calculate-statutory-sick-pay'

module SmartAnswer
  class CalculateStatutorySickPayFlowTest < ActiveSupport::TestCase
    context 'outcome decision' do
      setup do
        @lower_earning_limit = 100
        Calculators::StatutorySickPayCalculator.stubs(
          lower_earning_limit_on: @lower_earning_limit
        )
        @calculator = stub('calculator', {
          ssp_payment: 0,
          days_that_can_be_paid_for_this_period: 1
        })
        @flow = stub('flow', {
          employee_average_weekly_earnings: @lower_earning_limit,
          sick_start_date: anything,
          prior_sick_days: nil,
          calculator: @calculator
        })
        @decision = CalculateStatutorySickPayFlow::OutcomeDecision.new(@flow)
      end

      context 'employee average weekly earnings are less than lower earning limit' do
        setup do
          @flow.stubs(employee_average_weekly_earnings: @lower_earning_limit - 1)
        end

        should 'route to not_earned_enough outcome' do
          assert_equal :not_earned_enough, @decision.outcome_name
        end
      end

      context 'number of prior sick days has exceeded maximum allowed' do
        setup do
          @flow.stubs(prior_sick_days: 5 * 28 + 3, usual_work_days: '1,2,3,4,5')
        end

        should 'route to maximum_entitlement_reached outcome' do
          assert_equal :maximum_entitlement_reached, @decision.outcome_name
        end
      end

      context 'a statutory sick pay payment is due' do
        setup do
          @calculator.stubs(ssp_payment: 100)
        end

        should 'route to entitled_to_sick_pay outcome' do
          assert_equal :entitled_to_sick_pay, @decision.outcome_name
        end
      end

      context 'no days can be paid for this period' do
        setup do
          @calculator.stubs(days_that_can_be_paid_for_this_period: 0)
        end

        should 'route to maximum_entitlement_reached outcome' do
          assert_equal :maximum_entitlement_reached, @decision.outcome_name
        end
      end

      context 'otherwise' do
        should 'route to not_entitled_3_days_not_paid outcome' do
          assert_equal :not_entitled_3_days_not_paid, @decision.outcome_name
        end
      end
    end
  end
end
