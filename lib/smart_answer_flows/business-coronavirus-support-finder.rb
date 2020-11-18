module SmartAnswer
  class BusinessCoronavirusSupportFinderFlow < Flow
    def define
      start_page_content_id "89edffd2-3046-40bd-810c-cc1a13c05b6a"
      flow_content_id "1f589327-a6b3-4b5c-aea0-7a2752e2eddf"
      name "business-coronavirus-support-finder"
      status :draft

      radio :business_based? do
        option :england
        option :scotland
        option :wales
        option :northern_ireland

        on_response do |response|
          self.calculator = Calculators::BusinessCoronavirusSupportFinderCalculator.new
          calculator.business_based = response
        end

        next_node do
          question :business_size?
        end
      end

      radio :business_size? do
        option :"0_to_249"
        option :over_249

        on_response do |response|
          calculator.business_size = response
        end

        next_node do
          question :annual_turnover?
        end
      end

      radio :annual_turnover? do
        option :pre_revenue
        option :under_85k
        option :"85k_to_45m"
        option :"45m_to_500m"
        option :"500m_and_over"

        on_response do |response|
          calculator.annual_turnover = response
        end

        next_node do
          question :paye_scheme?
        end
      end

      radio :paye_scheme? do
        option :yes
        option :no

        on_response do |response|
          calculator.paye_scheme = response
        end

        next_node do
          question :self_employed?
        end
      end

      radio :self_employed? do
        option :yes
        option :no

        on_response do |response|
          calculator.self_employed = response
        end

        next_node do
          question :non_domestic_property?
        end
      end

      radio :non_domestic_property? do
        option :none
        option :under_51k
        option :"51k_and_over"

        on_response do |response|
          calculator.non_domestic_property = response
        end

        next_node do
          if calculator.non_domestic_property != "none"
            question :sectors?
          else
            question :restricted_sector?
          end
        end
      end

      checkbox_question :sectors? do
        option :retail_hospitality_or_leisure
        option :nurseries
        none_option

        on_response do |response|
          calculator.sectors = response.split(",")
        end

        next_node do
          question :rate_relief_march_2020?
        end
      end

      radio :rate_relief_march_2020? do
        option :yes
        option :no

        on_response do |response|
          calculator.rate_relief_march_2020 = response
        end

        next_node do
          outcome :restricted_sector?
        end
      end

      radio :restricted_sector? do
        option :yes
        option :no

        on_response do |response|
          calculator.restricted_sector = response
        end

        next_node do
          if calculator.restricted_sector == "yes"
            outcome :results
          else
            question :closed_by_restrictions?
          end
        end
      end

      radio :closed_by_restrictions? do
        option :yes_national
        option :yes_local
        option :yes_local_and_national
        option :no

        on_response do |response|
          if %w[yes_local yes_local_and_national].include?(response)
            calculator.closed_by_restrictions << "local"
          end

          if %w[yes_national yes_local_and_national].include?(response)
            calculator.closed_by_restrictions << "national"
          end
        end

        next_node do
          outcome :results
        end
      end

      outcome :results
    end
  end
end
