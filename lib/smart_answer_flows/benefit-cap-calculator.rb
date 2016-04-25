module SmartAnswer
  class BenefitCapCalculatorFlow < Flow
    def define
      content_id "ffe22070-123b-4390-8cc4-51f9d5b5cc74"
      name 'benefit-cap-calculator'
      status :published
      satisfies_need "100696"

      config = Calculators::BenefitCapCalculatorConfiguration.new

      # Routing question
      multiple_choice :choose_cap_to_calculate? do
        option :default
        option :future

        save_input_as :chosen_cap

        next_node do
          question :receive_housing_benefit?
        end
      end

      # Q1
      multiple_choice :receive_housing_benefit? do
        option :yes
        option :no

        save_input_as :housing_benefit

        next_node do |response|
          if response == 'yes'
            question :working_tax_credit?
          else
            if chosen_cap == 'future'
              outcome :outcome_not_affected_no_housing_benefit_future
            else
              outcome :outcome_not_affected_no_housing_benefit
            end
          end
        end
      end

      # Q2
      multiple_choice :working_tax_credit? do
        option :yes
        option :no

        next_node do |response|
          if response == 'yes'
            if chosen_cap == 'future'
              outcome :outcome_not_affected_exemptions_future
            else
              outcome :outcome_not_affected_exemptions
            end
          else
            question :receiving_exemption_benefits?
          end
        end
      end

      #Q3
      multiple_choice :receiving_exemption_benefits? do
        option :yes
        option :no

        precalculate :exempt_benefits do
          config.exempt_benefits(chosen_cap)
        end

        calculate :benefit_options do
          config.descriptions(chosen_cap).merge(none_above: "None of the above")
        end

        calculate :total_benefits do
          0
        end

        calculate :benefit_cap do
          0
        end

        next_node do |response|
          if response == 'yes'
            if chosen_cap == 'future'
              outcome :outcome_not_affected_exemptions_future
            else
              outcome :outcome_not_affected_exemptions
            end
          else
            if chosen_cap == 'future'
              question :receiving_non_exemption_benefits_future?
            else
              question :receiving_non_exemption_benefits?
            end
          end
        end
      end

      #Q4 default flow
      checkbox_question :receiving_non_exemption_benefits? do
        config.benefits(:default).keys.each do |benefit|
          option benefit
        end

        next_node_calculation :benefit_types do |response|
          response.split(",").map(&:to_sym)
        end

        next_node do |response|
          if response == "none"
            outcome :outcome_not_affected
          else
            question BenefitCapCalculatorFlow.next_benefit_amount_question(config.questions(chosen_cap), benefit_types)
          end
        end
      end

      #Q4 future flow
      checkbox_question :receiving_non_exemption_benefits_future? do
        config.benefits(:future).keys.each do |benefit|
          option benefit
        end

        next_node_calculation :benefit_types do |response|
          response.split(",").map(&:to_sym)
        end

        next_node do |response|
          if response == "none"
            outcome :outcome_not_affected_future
          else
            question BenefitCapCalculatorFlow.next_benefit_amount_question(config.questions(chosen_cap), benefit_types)
          end
        end
      end

      #Q5a-o
      config.all_questions.each do |(_benefit, method)|
        money_question method do
          calculate :total_benefits do |response|
            total_benefits + response.to_f
          end

          next_node do
            question BenefitCapCalculatorFlow.next_benefit_amount_question(config.questions(chosen_cap), benefit_types)
          end
        end
      end

      #Q5p
      money_question :housing_benefit_amount? do
        save_input_as :housing_benefit_amount

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        next_node do
          if chosen_cap == "future"
            question :single_couple_lone_parent_future?
          else
            question :single_couple_lone_parent?
          end
        end
      end

      #Q6 current flow
      multiple_choice :single_couple_lone_parent? do
        precalculate :weekly_benefit_cap_descriptions do
          config.weekly_benefit_cap_descriptions(chosen_cap)
        end

        config.weekly_benefit_caps(:default).keys.each do |weekly_benefit_cap|
          option weekly_benefit_cap
        end

        calculate :benefit_cap do |response|
          sprintf("%.2f", config.weekly_benefit_cap_amount(chosen_cap, response))
        end

        next_node do |response|
          if total_benefits > config.weekly_benefit_cap_amount(chosen_cap, response)
            outcome :outcome_affected_greater_than_cap
          else
            outcome :outcome_not_affected_less_than_cap
          end
        end
      end

      #Q6 future
      multiple_choice :single_couple_lone_parent_future? do
        precalculate :weekly_benefit_cap_descriptions do
          config.weekly_benefit_cap_descriptions(chosen_cap)
        end

        config.weekly_benefit_caps(:future).keys.each do |weekly_benefit_cap|
          option weekly_benefit_cap
        end

        save_input_as :family_type

        next_node do
          question :enter_postcode?
        end
      end

      #Q7 Future flow - Enter a postcode
      postcode_question :enter_postcode? do
        calculate :benefit_cap do |response|
          sprintf("%.2f", config.weekly_benefit_cap_amount(chosen_cap, family_type, config.region(response)))
        end

        next_node do |response|
          region = config.region(response)
          if total_benefits > config.weekly_benefit_cap_amount(chosen_cap, family_type, region)
            if region == :london
              outcome :outcome_affected_greater_than_cap_future_london
            else
              outcome :outcome_affected_greater_than_cap_future_national
            end
          else
            if region == :london
              outcome :outcome_not_affected_less_than_cap_future_london
            else
              outcome :outcome_not_affected_less_than_cap_future_national
            end
          end
        end
      end

      ##OUTCOMES

      ## Outcome 1
      outcome :outcome_not_affected_exemptions do
        precalculate :exempt_benefits do
          config.exempt_benefits(chosen_cap)
        end
      end

      outcome :outcome_not_affected_exemptions_future do
        precalculate :exempt_benefits do
          config.exempt_benefits(chosen_cap)
        end
      end

      ## Outcome 2
      outcome :outcome_not_affected_no_housing_benefit
      outcome :outcome_not_affected_no_housing_benefit_future

      ## Outcome 3
      outcome :outcome_affected_greater_than_cap do
        precalculate :total_benefits do
          sprintf("%.2f", total_benefits)
        end

        precalculate :housing_benefit_amount do
          sprintf("%.2f", housing_benefit_amount)
        end

        precalculate :total_over_cap do
          sprintf("%.2f", (total_benefits.to_f - benefit_cap.to_f))
        end

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

      outcome :outcome_affected_greater_than_cap_future_london do
        precalculate :total_benefits do
          sprintf("%.2f", total_benefits)
        end

        precalculate :housing_benefit_amount do
          sprintf("%.2f", housing_benefit_amount)
        end

        precalculate :total_over_cap do
          sprintf("%.2f", (total_benefits.to_f - benefit_cap.to_f))
        end

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

      outcome :outcome_affected_greater_than_cap_future_national do
        precalculate :total_benefits do
          sprintf("%.2f", total_benefits)
        end

        precalculate :housing_benefit_amount do
          sprintf("%.2f", housing_benefit_amount)
        end

        precalculate :total_over_cap do
          sprintf("%.2f", (total_benefits.to_f - benefit_cap.to_f))
        end

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

      ## Outcome 4
      outcome :outcome_not_affected_less_than_cap do
        precalculate :total_benefits do
          sprintf("%.2f", total_benefits)
        end
      end
      outcome :outcome_not_affected_less_than_cap_future_london do
        precalculate :total_benefits do
          sprintf("%.2f", total_benefits)
        end
      end
      outcome :outcome_not_affected_less_than_cap_future_national do
        precalculate :total_benefits do
          sprintf("%.2f", total_benefits)
        end
      end

      ## Outcome 5
      outcome :outcome_not_affected
      outcome :outcome_not_affected_future
    end

    def self.next_benefit_amount_question(benefits, selected_benefits)
      benefits.fetch(selected_benefits.shift, :housing_benefit_amount?)
    end
  end
end
