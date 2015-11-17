module SmartAnswer
  class StatePensionThroughPartnerFlow < Flow
    def define
      content_id "42a41808-b338-4e4b-a703-47195982f4c8"
      name 'state-pension-through-partner'
      status :published
      satisfies_need "100578"

      ### This will need updating before 6th April 2016 ###
      # Q1
      multiple_choice :what_is_your_marital_status? do
        option :married
        option :will_marry_before_specific_date
        option :will_marry_on_or_after_specific_date
        option :widowed
        option :divorced

        save_input_as :marital_status

        calculate :answers do |response|
          answers = []
          if response == "married" or response == "will_marry_before_specific_date"
            answers << :old1
          elsif response == "will_marry_on_or_after_specific_date"
            answers << :new1
          elsif response == "widowed"
            answers << :widow
          end
          answers
        end

        calculate :lower_basic_state_pension_rate do
          rate = SmartAnswer::Calculators::RatesQuery.new('state_pension').rates.lower_weekly_rate
          "£#{rate}"
        end
        calculate :higher_basic_state_pension_rate do
          rate = SmartAnswer::Calculators::RatesQuery.new('state_pension').rates.weekly_rate
          "£#{rate}"
        end

        permitted_next_nodes = [
          :what_is_your_gender?,
          :when_will_you_reach_pension_age?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'divorced'
            :what_is_your_gender?
          else
            :when_will_you_reach_pension_age?
          end
        end
      end

      # Q2
      multiple_choice :when_will_you_reach_pension_age? do
        option :your_pension_age_before_specific_date
        option :your_pension_age_after_specific_date

        save_input_as :when_will_you_reach_pension_age

        calculate :answers do |response|
          if response == "your_pension_age_before_specific_date"
            answers << :old2
          elsif response == "your_pension_age_after_specific_date"
            answers << :new2
          end
          answers << :old3 if marital_status == "widowed"
          answers
        end

        next_node_calculation(:widow_and_new_pension) do |response|
          answers == [:widow] && response == "your_pension_age_after_specific_date"
        end

        next_node_calculation(:widow_and_old_pension) do |response|
          answers == [:widow] && response == "your_pension_age_before_specific_date"
        end

        permitted_next_nodes = [
          :what_is_your_gender?,
          :when_will_your_partner_reach_pension_age?,
          :widow_and_old_pension_outcome
        ]
        next_node(permitted: permitted_next_nodes) do
          if widow_and_new_pension
            :what_is_your_gender?
          elsif widow_and_old_pension
            :widow_and_old_pension_outcome
          else
            :when_will_your_partner_reach_pension_age?
          end
        end
      end

      #Q3
      multiple_choice :when_will_your_partner_reach_pension_age? do
        option :partner_pension_age_before_specific_date
        option :partner_pension_age_after_specific_date

        next_node_calculation :answers do |response|
          if response == "partner_pension_age_before_specific_date"
            answers << :old3
          elsif response == "partner_pension_age_after_specific_date"
            answers << :new3
          end
          answers
        end

        next_node_calculation(:current_rules_no_additional_pension) {
          answers == [:old1, :old2, :old3] || answers == [:new1, :old2, :old3]
        }

        next_node_calculation(:current_rules_national_insurance_no_state_pension) {
          answers == [:old1, :old2, :new3] || answers == [:new1, :old2, :new3]
        }

        permitted_next_nodes = [
          :current_rules_national_insurance_no_state_pension_outcome,
          :current_rules_no_additional_pension_outcome,
          :what_is_your_gender?
        ]
        next_node(permitted: permitted_next_nodes) do
          if current_rules_no_additional_pension
            :current_rules_no_additional_pension_outcome
          elsif current_rules_national_insurance_no_state_pension
            :current_rules_national_insurance_no_state_pension_outcome
          else
            :what_is_your_gender?
          end
        end
      end

      # Q4
      multiple_choice :what_is_your_gender? do
        option :male_gender
        option :female_gender

        save_input_as :gender

        on_condition(responded_with("male_gender")) do
          next_node_if(:impossibility_due_to_divorce_outcome, variable_matches(:marital_status, "divorced"))
          next_node(:impossibility_to_increase_pension_outcome)
        end
        on_condition(responded_with("female_gender")) do
          next_node_if(:age_dependent_pension_outcome, variable_matches(:marital_status, "divorced"))
          next_node_if(:married_woman_and_state_pension_outcome, variable_matches(:marital_status, "widowed"))
          next_node(:married_woman_no_state_pension_outcome)
        end
      end

      outcome :widow_and_old_pension_outcome

      outcome :current_rules_no_additional_pension_outcome
      outcome :current_rules_national_insurance_no_state_pension_outcome

      outcome :impossibility_due_to_divorce_outcome
      outcome :impossibility_to_increase_pension_outcome

      outcome :age_dependent_pension_outcome
      outcome :married_woman_and_state_pension_outcome
      outcome :married_woman_no_state_pension_outcome
    end
  end
end
