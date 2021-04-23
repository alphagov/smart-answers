module SmartAnswer
  class NextStepsForYourBusinessFlow < Flow
    def define
      name "next-steps-for-your-business"
      content_id "4d7751b5-d860-4812-aa36-5b8c57253ff2"
      status :draft
      response_store :query_parameters

      # ======================================================================
      # Will your business take more than £85,000 in a 12 month period?
      # ======================================================================
      radio :annual_turnover do
        option :more_than_85k
        option :less_than_85k
        option :not_sure

        on_response do |response|
          self.calculator = Calculators::NextStepsForYourBusinessCalculator.new
          calculator.annual_turnover = response
        end

        next_node do
          question :employ_someone
        end
      end

      # ======================================================================
      # Do you want to employ someone?
      # ======================================================================
      radio :employ_someone do
        option :yes
        option :already_employ
        option :no
        option :not_sure

        on_response do |response|
          calculator.employ_someone = response
        end

        next_node do
          question :business_intent
        end
      end

      # ======================================================================
      # Does your business do any of the following?
      # ======================================================================
      checkbox_question :business_intent do
        option :buy_abroad
        option :sell_abroad
        option :sell_online
        none_option

        on_response do |response|
          calculator.business_intent = response.split(",")
        end

        next_node do
          question :financial_support
        end
      end

      # ======================================================================
      # Are you looking for financial support for:
      # ======================================================================
      radio :financial_support do
        option :yes
        option :no

        on_response do |response|
          calculator.financial_support = response
        end

        next_node do
          question :business_premises
        end
      end

      # ======================================================================
      # Where are you running your business?
      # ======================================================================
      radio :business_premises do
        option :home
        option :renting
        option :elsewhere

        on_response do |response|
          calculator.business_premises = response
        end

        next_node do
          outcome :results
        end
      end

      # ======================================================================
      # Outcome
      # ======================================================================
      outcome :results do
        view_template "smart_answers/custom_result"
      end
    end
  end
end
