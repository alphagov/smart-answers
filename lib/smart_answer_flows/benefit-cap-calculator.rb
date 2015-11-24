module SmartAnswer
  class BenefitCapCalculatorFlow < Flow
    def define
      content_id "ffe22070-123b-4390-8cc4-51f9d5b5cc74"
      name 'benefit-cap-calculator'
      status :published
      satisfies_need "100696"

      use_erb_templates_for_questions

      # Q1
      multiple_choice :receive_housing_benefit? do
        option :yes
        option :no

        save_input_as :housing_benefit

        permitted_next_nodes = [
          :working_tax_credit?,
          :outcome_not_affected_no_housing_benefit
        ]

        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'yes'
            :working_tax_credit?
          else
            :outcome_not_affected_no_housing_benefit
          end
        end
      end

      # Q2
      multiple_choice :working_tax_credit? do
        option :yes
        option :no

        permitted_next_nodes = [
          :outcome_not_affected_exemptions,
          :receiving_exemption_benefits?
        ]

        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'yes'
            :outcome_not_affected_exemptions
          else
            :receiving_exemption_benefits?
          end
        end
      end

      #Q3
      multiple_choice :receiving_exemption_benefits? do
        option :yes
        option :no

        permitted_next_nodes = [
          :outcome_not_affected_exemptions,
          :receiving_non_exemption_benefits?
        ]

        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'yes'
            :outcome_not_affected_exemptions
          else
            :receiving_non_exemption_benefits?
          end
        end
      end

      #Q4
      checkbox_question :receiving_non_exemption_benefits? do
        option :bereavement
        option :carers
        option :child_benefit
        option :child_tax
        option :esa
        option :guardian
        option :incapacity
        option :income_support
        option :jsa
        option :maternity
        option :sda
        option :widowed_mother
        option :widowed_parent
        option :widow_pension
        option :widows_aged

        calculate :benefit_related_questions do |response|
          questions = response.split(",").map { |r| :"#{r}_amount?" }
          questions << :housing_benefit_amount? if housing_benefit == 'yes'
          questions << :single_couple_lone_parent?
          questions.shift
          questions
        end

        calculate :total_benefits do
          0
        end

        calculate :benefit_cap do
          0
        end

        permitted_next_nodes = [
          :outcome_not_affected,
          :bereavement_amount?,
          :carers_amount?,
          :child_benefit_amount?,
          :child_tax_amount?,
          :esa_amount?,
          :guardian_amount?,
          :incapacity_amount?,
          :income_support_amount?,
          :jsa_amount?,
          :maternity_amount?,
          :sda_amount?,
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do |response|
          first_value = response.split(",").first
          if response == "none"
            :outcome_not_affected
          else
            :"#{first_value}_amount?"
          end
        end
      end

      #Q5a
      money_question :bereavement_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :carers_amount?,
          :child_benefit_amount?,
          :child_tax_amount?,
          :esa_amount?,
          :guardian_amount?,
          :incapacity_amount?,
          :income_support_amount?,
          :jsa_amount?,
          :maternity_amount?,
          :sda_amount?,
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5b
      money_question :carers_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :child_benefit_amount?,
          :child_tax_amount?,
          :esa_amount?,
          :guardian_amount?,
          :incapacity_amount?,
          :income_support_amount?,
          :jsa_amount?,
          :maternity_amount?,
          :sda_amount?,
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5c
      money_question :child_benefit_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :child_tax_amount?,
          :esa_amount?,
          :guardian_amount?,
          :incapacity_amount?,
          :income_support_amount?,
          :jsa_amount?,
          :maternity_amount?,
          :sda_amount?,
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5d
      money_question :child_tax_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :esa_amount?,
          :guardian_amount?,
          :incapacity_amount?,
          :income_support_amount?,
          :jsa_amount?,
          :maternity_amount?,
          :sda_amount?,
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5e
      money_question :esa_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :guardian_amount?,
          :incapacity_amount?,
          :income_support_amount?,
          :jsa_amount?,
          :maternity_amount?,
          :sda_amount?,
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5f
      money_question :guardian_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :incapacity_amount?,
          :income_support_amount?,
          :jsa_amount?,
          :maternity_amount?,
          :sda_amount?,
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5g
      money_question :incapacity_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :income_support_amount?,
          :jsa_amount?,
          :maternity_amount?,
          :sda_amount?,
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5h
      money_question :income_support_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :jsa_amount?,
          :maternity_amount?,
          :sda_amount?,
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5i
      money_question :jsa_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :maternity_amount?,
          :sda_amount?,
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5j
      money_question :maternity_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :sda_amount?,
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5k
      money_question :sda_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :widow_pension_amount?,
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5n
      money_question :widow_pension_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :widowed_mother_amount?,
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5l
      money_question :widowed_mother_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :widowed_parent_amount?,
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5m
      money_question :widowed_parent_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :widows_aged_amount?,
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5o
      money_question :widows_aged_amount? do

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [
          :housing_benefit_amount?,
          :single_couple_lone_parent?
        ]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q5p
      money_question :housing_benefit_amount? do

        save_input_as :housing_benefit_amount

        calculate :total_benefits do |response|
          total_benefits + response.to_f
        end

        permitted_next_nodes = [:single_couple_lone_parent?]

        next_node(permitted: permitted_next_nodes) do
          benefit_related_questions.shift
        end
      end

      #Q6
      multiple_choice :single_couple_lone_parent? do
        option :single
        option :couple
        option :parent

        calculate :benefit_cap do |response|
          if response == 'single'
            benefit_cap = 350
          else
            benefit_cap = 500
          end
          sprintf("%.2f", benefit_cap)
        end

        permitted_next_nodes = [
          :outcome_affected_greater_than_cap,
          :outcome_not_affected_less_than_cap
        ]

        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'single'
            cap = 350
          else
            cap = 500
          end

          if total_benefits > cap
            :outcome_affected_greater_than_cap
          else
            :outcome_not_affected_less_than_cap
          end
        end
      end

      ##OUTCOMES

      ## Outcome 1
      outcome :outcome_not_affected_exemptions

      ## Outcome 2
      outcome :outcome_not_affected_no_housing_benefit

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

      ## Outcome 4
      outcome :outcome_not_affected_less_than_cap do
        precalculate :total_benefits do
          sprintf("%.2f", total_benefits)
        end

      end

      ## Outcome 5
      outcome :outcome_not_affected
    end
  end
end
