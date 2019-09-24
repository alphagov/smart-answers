module SmartAnswer
  class StatePensionThroughPartnerFlow < Flow
    def define
      start_page_content_id "42a41808-b338-4e4b-a703-47195982f4c8"
      flow_content_id "8e80445f-b987-4f71-bc86-282b2779a4de"
      name "state-pension-through-partner"
      status :published
      satisfies_need "100578"

      # Q1
      multiple_choice :what_is_your_marital_status? do
        option :married
        option :widowed
        option :divorced

        on_response do |response|
          self.calculator = Calculators::StatePensionThroughPartnerCalculator.new
          calculator.marital_status = response
        end

        next_node do
          if calculator.divorced?
            question :what_is_your_gender?
          else
            question :when_will_you_reach_pension_age?
          end
        end
      end

      # Q2
      multiple_choice :when_will_you_reach_pension_age? do
        option :your_pension_age_before_specific_date
        option :your_pension_age_after_specific_date

        on_response do |response|
          calculator.when_will_you_reach_pension_age = response
        end

        next_node do
          if calculator.widow_and_new_pension?
            question :what_is_your_gender?
          elsif calculator.widow_and_old_pension?
            outcome :widow_and_old_pension_outcome
          else
            question :when_will_your_partner_reach_pension_age?
          end
        end
      end

      #Q3
      multiple_choice :when_will_your_partner_reach_pension_age? do
        option :partner_pension_age_before_specific_date
        option :partner_pension_age_after_specific_date

        on_response do |response|
          calculator.when_will_your_partner_reach_pension_age = response
        end

        next_node do
          if calculator.current_rules_no_additional_pension?
            outcome :current_rules_no_additional_pension_outcome
          elsif calculator.current_rules_national_insurance_no_state_pension?
            outcome :current_rules_national_insurance_no_state_pension_outcome
          else
            question :what_is_your_gender?
          end
        end
      end

      # Q4
      multiple_choice :what_is_your_gender? do
        option :male_gender
        option :female_gender

        on_response do |response|
          calculator.gender = response
        end

        next_node do
          if calculator.male?
            if calculator.divorced?
              outcome :impossibility_due_to_divorce_outcome
            elsif calculator.widowed?
              outcome :widow_male_reaching_pension_age
            else
              outcome :impossibility_to_increase_pension_outcome
            end
          elsif calculator.female?
            if calculator.divorced?
              outcome :age_dependent_pension_outcome
            elsif calculator.widowed?
              outcome :married_woman_and_state_pension_outcome
            else
              outcome :married_woman_no_state_pension_outcome
            end
          end
        end
      end

      # Outcome list below. NB: outcomes 4 and 7 are not available
      outcome :current_rules_no_additional_pension_outcome # Outcome 1
      outcome :widow_and_old_pension_outcome # Outcome 2
      outcome :current_rules_national_insurance_no_state_pension_outcome # Outcome 3

      outcome :married_woman_no_state_pension_outcome # Outcome 5
      outcome :married_woman_and_state_pension_outcome # Outcome 6

      outcome :impossibility_to_increase_pension_outcome # Outcome 8a
      outcome :widow_male_reaching_pension_age # Outcome 8b

      outcome :impossibility_due_to_divorce_outcome # Outcome 9
      outcome :age_dependent_pension_outcome # Outcome 10
    end
  end
end
