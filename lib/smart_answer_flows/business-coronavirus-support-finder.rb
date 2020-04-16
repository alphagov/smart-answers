module SmartAnswer
  class BusinessCoronavirusSupportFinderFlow < Flow
    def define
      start_page_content_id "89edffd2-3046-40bd-810c-cc1a13c05b6a"
      flow_content_id "1f589327-a6b3-4b5c-aea0-7a2752e2eddf"
      name "business-coronavirus-support-finder"
      status :draft

      # Q1
      multiple_choice :business_based? do
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

      # Q2
      multiple_choice :business_size? do
        option :"0_to_249"
        option :over_249

        on_response do |response|
          calculator.business_size = response
        end

        next_node do
          question :annual_turnover?
        end
      end

      # Q3
      multiple_choice :annual_turnover? do
        option :"500m_and_over"
        option :"45m_to_500m"
        option :"85k_to_45m"
        option :under_85k

        on_response do |response|
          calculator.annual_turnover = response
        end

        next_node do
          question :paye_scheme?
        end
      end

      # Q4
      multiple_choice :paye_scheme? do
        option :yes
        option :no

        on_response do |response|
          calculator.paye_scheme = response
        end

        next_node do
          question :self_employed?
        end
      end

      # Q5
      multiple_choice :self_employed? do
        option :yes
        option :no

        on_response do |response|
          calculator.self_employed = response
        end

        next_node do
          question :non_domestic_property?
        end
      end

      # Q6
      multiple_choice :non_domestic_property? do
        option :"51k_and_over"
        option :under_51k
        option :none

        on_response do |response|
          calculator.non_domestic_property = response
        end

        next_node do
          question :sectors?
        end
      end

      # Q7
      checkbox_question :sectors? do
        option :retail_hospitality_or_leisure
        option :nurseries
        set_none_option(label: "None of the above")

        on_response do |response|
          calculator.sectors = response.split(",")
        end

        next_node do
          question :self_assessment_july_2020?
        end
      end

      # Q8
      multiple_choice :self_assessment_july_2020? do
        option :yes
        option :no

        on_response do |response|
          calculator.self_assessment_july_2020 = response
        end

        next_node do
          outcome :results
        end
      end

      outcome :results
    end
  end
end
