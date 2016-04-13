require_relative "../../test_helper"
require "smart_answer_flows/benefit-cap-calculator"

module SmartAnswer
  class BenefitCapCalculatorFlowTest < ActiveSupport::TestCase
    context BenefitCapCalculatorFlow do
      setup do
        @questions = {
          first_benefit: :first_benefit_amount?,
          second_benefit: :second_benefit_amount?,
          third_benefit: :third_benefit_amount?,
          fourth_benefit: :fourth_benefit_amount?
        }

        @selected_benefits = [:second_benefit, :fourth_benefit]
      end

      context "order of questions asked" do
        should "ask the next benefit amount question in the selected_benefits list" do
          # Should ask the first question in the selected benefits list
          assert_equal :second_benefit_amount?,
            BenefitCapCalculatorFlow.next_benefit_amount_question(@questions, @selected_benefits)

          # The selected benefits list should only contain unasked questions
          assert_equal [:fourth_benefit], @selected_benefits

          # Should ask the next question in the selected benefits list
          assert_equal :fourth_benefit_amount?,
            BenefitCapCalculatorFlow.next_benefit_amount_question(@questions, @selected_benefits)

          # After all questions have been asked, there should not be any unasked
          # questions in selected_benefits
          assert_equal [], @selected_benefits
        end
      end
    end
  end
end
