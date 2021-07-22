class BenefitCapCalculatorFlow < SmartAnswer::Flow
  def define
    content_id "ffe22070-123b-4390-8cc4-51f9d5b5cc74"
    name "benefit-cap-calculator"
    status :published

    calculator = SmartAnswer::Calculators::BenefitCapCalculatorConfiguration

    # Q1
    radio :receive_housing_benefit? do
      option :yes
      option :no

      on_response do |response|
        self.calculator = calculator
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

      on_response do
        self.exempt_benefits_descriptions = calculator.exempt_benefits.values
        self.exempt_benefits = calculator.exempt_benefits
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
      calculator.exempt_benefits.each_key do |exempt_benefit|
        option exempt_benefit
      end

      on_response do
        self.benefit_options = calculator.descriptions.merge(none_above: "None of the above")
        self.total_benefits = 0
        self.benefit_cap = 0
      end

      next_node do |response|
        if calculator.exempted_benefits?(response.split(","))
          outcome :outcome_not_affected_exemptions
        else
          question :receiving_non_exemption_benefits?
        end
      end
    end

    # Q4
    checkbox_question :receiving_non_exemption_benefits? do
      calculator.benefits.each_key do |benefit|
        option benefit
      end

      on_response do |response|
        self.benefit_types = response.split(",").map(&:to_sym)
      end

      next_node do |response|
        if response == "none"
          question :housing_benefit_amount?
        else
          question BenefitCapCalculatorFlow.next_benefit_amount_question(calculator.questions, benefit_types)
        end
      end
    end

    # Q5a-o
    calculator.questions.each do |(_benefit, method)|
      money_question method do
        on_response do |response|
          self.total_benefits = total_benefits + response.to_f
        end

        next_node do
          question BenefitCapCalculatorFlow.next_benefit_amount_question(calculator.questions, benefit_types)
        end
      end
    end

    # Q5p
    money_question :housing_benefit_amount? do
      on_response do |response|
        self.housing_benefit_amount = response
        self.total_benefits += housing_benefit_amount.to_f
        self.housing_benefit_amount = sprintf("%.2f", housing_benefit_amount)
      end

      next_node do
        question :single_couple_lone_parent?
      end
    end

    # Q6
    radio :single_couple_lone_parent? do
      calculator.weekly_benefit_caps.each_key do |weekly_benefit_cap|
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
      on_response do |response|
        self.benefit_cap = sprintf("%.2f", calculator.weekly_benefit_cap_amount(family_type, calculator.region(response)))
        self.total_benefits_amount = sprintf("%.2f", total_benefits)
        self.total_over_cap = sprintf("%.2f", (total_benefits.to_f - benefit_cap.to_f))
      end

      next_node do |response|
        region = calculator.region(response)
        if total_benefits > calculator.weekly_benefit_cap_amount(family_type, region)
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
    outcome :outcome_affected_greater_than_cap_london

    ## Outcome 10
    outcome :outcome_affected_greater_than_cap_national

    ## Outcome 9
    outcome :outcome_not_affected_less_than_cap_london

    ## Outcome 11
    outcome :outcome_not_affected_less_than_cap_national
  end

  def self.next_benefit_amount_question(benefits, selected_benefits)
    benefits.fetch(selected_benefits.shift, :housing_benefit_amount?)
  end
end
