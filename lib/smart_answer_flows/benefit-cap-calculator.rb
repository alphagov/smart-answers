module SmartAnswer
  class BenefitCapCalculatorFlow < Flow
    def define
      start_page_content_id "ffe22070-123b-4390-8cc4-51f9d5b5cc74"
      flow_content_id "d2593a1a-441b-4751-8bf7-ed04a8fd8689"
      name "benefit-cap-calculator"
      status :published
      satisfies_need "8474ef2f-6bc2-44be-8883-8a795d728c51"

      config = Calculators::BenefitCapCalculatorConfiguration.new

      # Q1
      radio :receive_housing_benefit? do
        option :yes
        option :no

        on_response do |response|
          self.housing_benefit = response
        end

        next_node do |response|
          if response == "yes"
            question :working_tax_credit?
          else
            outcome :outcome_not_affected_no_housing_benefit
          end
        end
      end

      # Q2
      radio :working_tax_credit? do
        option :yes
        option :no

        calculate :exempt_benefits_descriptions do
          config.exempt_benefits.values
        end

        calculate :exempt_benefits do
          config.exempt_benefits
        end

        next_node do |response|
          if response == "yes"
            outcome :outcome_not_affected_exemptions
          else
            question :receiving_exemption_benefits?
          end
        end
      end

      # Q3
      checkbox_question :receiving_exemption_benefits? do
        config.exempt_benefits.each_key do |exempt_benefit|
          option exempt_benefit
        end

        on_response do |response|
          config.exempted_benefits = response.split(",")
        end

        calculate :benefit_options do
          config.descriptions.merge(none_above: "None of the above")
        end

        calculate :total_benefits do
          0
        end

        calculate :benefit_cap do
          0
        end

        next_node do
          if config.exempted_benefits?
            outcome :outcome_not_affected_exemptions
          else
            question :receiving_non_exemption_benefits?
          end
        end
      end

      # Q4
      checkbox_question :receiving_non_exemption_benefits? do
        config.benefits.each_key do |benefit|
          option benefit
        end

        on_response do |response|
          self.benefit_types = response.split(",").map(&:to_sym)
        end

        next_node do |response|
          if response == "none"
            question :housing_benefit_amount?
          else
            question BenefitCapCalculatorFlow.next_benefit_amount_question(config.questions, benefit_types)
          end
        end
      end

      # Q5a-o
      config.questions.each do |(_benefit, method)|
        money_question method do
          calculate :total_benefits do |response|
            total_benefits + response.to_f
          end

          next_node do
            question BenefitCapCalculatorFlow.next_benefit_amount_question(config.questions, benefit_types)
          end
        end
      end

      # Q5p
      money_question :housing_benefit_amount? do
        on_response do |response|
          self.housing_benefit_amount = response
        end

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        calculate :housing_benefit_amount do
          sprintf("%.2f", housing_benefit_amount)
        end

        next_node do
          question :single_couple_lone_parent?
        end
      end

      # Q6
      radio :single_couple_lone_parent? do
        precalculate :weekly_benefit_cap_descriptions do
          config.weekly_benefit_cap_descriptions
        end

        config.weekly_benefit_caps.each_key do |weekly_benefit_cap|
          option weekly_benefit_cap
        end

        on_response do |response|
          self.family_type = response
        end

        next_node do
          question :enter_postcode?
        end
      end

      # Q7 Enter a postcode
      postcode_question :enter_postcode? do
        calculate :benefit_cap do |response|
          sprintf("%.2f", config.weekly_benefit_cap_amount(family_type, config.region(response)))
        end

        calculate :total_benefits_amount do
          sprintf("%.2f", total_benefits)
        end

        calculate :total_over_cap do
          sprintf("%.2f", (total_benefits.to_f - benefit_cap.to_f))
        end

        next_node do |response|
          region = config.region(response)
          if total_benefits > config.weekly_benefit_cap_amount(family_type, region)
            if region == :london
              outcome :outcome_affected_greater_than_cap_london
            else
              outcome :outcome_affected_greater_than_cap_national
            end
          elsif region == :london
            outcome :outcome_not_affected_less_than_cap_london
          else
            outcome :outcome_not_affected_less_than_cap_national
          end
        end
      end

      # #OUTCOMES

      ## Outcome 1
      outcome :outcome_not_affected_exemptions

      ## Outcome 2
      outcome :outcome_not_affected_no_housing_benefit

      ## Outcome 8
      outcome :outcome_affected_greater_than_cap_london do
        precalculate :new_housing_benefit_amount do
          housing_benefit_amount.to_f - total_over_cap.to_f
        end

        precalculate :new_housing_benefit do
          amount = sprintf("%.2f", new_housing_benefit_amount)
          if amount < "0.5"
            amount = sprintf("%.2f", 0.5)
          end
          amount
        end
      end

      ## Outcome 10
      outcome :outcome_affected_greater_than_cap_national do
        precalculate :new_housing_benefit_amount do
          housing_benefit_amount.to_f - total_over_cap.to_f
        end

        precalculate :new_housing_benefit do
          amount = sprintf("%.2f", new_housing_benefit_amount)
          if amount < "0.5"
            amount = sprintf("%.2f", 0.5)
          end
          amount
        end
      end

      ## Outcome 9
      outcome :outcome_not_affected_less_than_cap_london
      ## Outcome 11
      outcome :outcome_not_affected_less_than_cap_national
    end

    def self.next_benefit_amount_question(benefits, selected_benefits)
      benefits.fetch(selected_benefits.shift, :housing_benefit_amount?)
    end
  end
end
