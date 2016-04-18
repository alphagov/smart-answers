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
        option :widowed
        option :divorced

        save_input_as :marital_status

        calculate :answers do |response|
          answers = []
          if response == "married"
            answers << :old1
          elsif response == "widowed"
            answers << :widow
          end
          answers
        end

        calculate :lower_basic_state_pension_rate do
          rate = Calculators::RatesQuery.from_file('state_pension').rates.lower_weekly_rate
          "£#{'%.2f' % rate}"
        end
        calculate :higher_basic_state_pension_rate do
          rate = Calculators::RatesQuery.from_file('state_pension').rates.weekly_rate
          "£#{'%.2f' % rate}"
        end

        next_node do |response|
          if response == 'divorced'
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

        next_node do
          if widow_and_new_pension
            question :what_is_your_gender?
          elsif widow_and_old_pension
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

        next_node do
          if current_rules_no_additional_pension
            outcome :current_rules_no_additional_pension_outcome
          elsif current_rules_national_insurance_no_state_pension
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

        save_input_as :gender

        next_node do |response|
          case response
          when 'male_gender'
            if marital_status == 'divorced'
              outcome :impossibility_due_to_divorce_outcome
            elsif marital_status == 'widowed'
              outcome :widow_male_reaching_pension_age
            else
              outcome :impossibility_to_increase_pension_outcome
            end
          when 'female_gender'
            if marital_status == 'divorced'
              outcome :age_dependent_pension_outcome
            elsif marital_status == 'widowed'
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
