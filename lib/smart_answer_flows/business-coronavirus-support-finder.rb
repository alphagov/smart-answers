module SmartAnswer
  class BusinessCoronavirusSupportFinderFlow < Flow
    def define
      content_id "89edffd2-3046-40bd-810c-cc1a13c05b6a"
      name "business-coronavirus-support-finder"
      status :published

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
          question :non_domestic_property?
        end
      end

      radio :non_domestic_property? do
        option :yes
        option :no
        option :not_sure

        on_response do |response|
          calculator.non_domestic_property = response
        end

        next_node do
          question :sectors?
        end
      end

      checkbox_question :sectors? do
        option :nurseries
        option :retail_hospitality_or_leisure
        option :nightclubs_or_adult_entertainment
        option :personal_care
        none_option

        on_response do |response|
          calculator.sectors = response.split(",")
        end

        next_node do
          if calculator.sectors == %w[nightclubs_or_adult_entertainment]
            outcome :results
          else
            question :closed_by_restrictions?
          end
        end
      end

      checkbox_question :closed_by_restrictions? do
        option :local_1
        option :local_2
        option :national
        none_option

        on_response do |response|
          responses = response.split(",")

          calculator.closed_by_restrictions << "local" if (%w[local_1 local_2] & responses).present?
          calculator.closed_by_restrictions << "national" if responses.include?("national")
        end

        next_node do
          outcome :results
        end
      end

      outcome :results
    end
  end
end
