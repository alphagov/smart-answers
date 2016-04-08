require_relative "../../test_helper"
require "smart_answer_flows/benefit-cap-calculator"

module SmartAnswer
  class BenefitCapCalculatorFlowTest < ActiveSupport::TestCase
    context BenefitCapCalculatorFlow do
      setup do
        @benefits = {
          first_benefit: :first_benefit_amount?,
          second_benefit: :second_benefit_amount?,
          third_benefit: :third_benefit_amount?,
          fourth_benefit: :fourth_benefit_amount?
        }

        @selected_benefits = [:second_benefit, :fourth_benefit]
      end
      context "next question" do
        should "go the the next selected benefit question" do
          assert_equal :second_benefit_amount?,
            BenefitCapCalculatorFlow.next_benefit_amount_question(@benefits, @selected_benefits)
          assert_equal :fourth_benefit_amount?,
            BenefitCapCalculatorFlow.next_benefit_amount_question(@benefits, @selected_benefits)
        end
      end
    end
  end
end
