module SmartAnswer
  class CalculateYourChildMaintenanceFlow < Flow
    def define
      start_page_content_id "42c2e944-7977-4297-b142-aa9406756dd2"
      flow_content_id "064f2c7e-e838-4e45-8ab0-95613eb9d409"
      name 'calculate-your-child-maintenance'
      status :published
      satisfies_need "100147"
      external_related_links [
        {
          title: "Child Maintenance Options - How much should be paid",
          url: "http://www.cmoptions.org/en/maintenance/how-much.asp"
        },
        {
          title: "Child Maintenance Options - Ways to pay",
          url: "http://www.cmoptions.org/en/maintenance/ways-to-pay.asp"
        },
      ]

      ## Q0
      multiple_choice :are_you_paying_or_receiving? do
        option :pay
        option :receive

        on_response do |response|
          self.calculator = Calculators::ChildMaintenanceCalculator.new
          calculator.paying_or_receiving = response
        end

        next_node do
          question :how_many_children_paid_for?
        end
      end

      ## Q1
      multiple_choice :how_many_children_paid_for? do
        option "1_child"
        option "2_children"
        option "3_children"

        on_response do |response|
          ## to_i will look for the first integer in the string
          calculator.number_of_children = response.to_i
        end

        next_node do
          question :gets_benefits?
        end
      end

      ## Q2
      checkbox_question :gets_benefits? do
        option :income_support
        option :ib_jobseekers_allowance
        option :employment_support_allowance
        option :pension_credit
        option :cb_jobseekers_allowance
        option :cb_employment_support_llowance
        option :state_pension
        option :incapacity_benefit
        option :training_allowance
        option :armed_forces_compensation_scheme_payments
        option :war_disablement_pension
        option :bereavement_allowance
        option :carers_allowance
        option :maternity_allowance
        option :severe_disablement_allowance
        option :industrial_injuries_disablement_benefit
        option :widowed_parents_allowance
        option :widows_pension
        option :universal_credit_no_earned_income
        option :skillseekers_training
        option :war_partner_pension

        on_response do |response|
          calculator.benefits = response.split(",")
        end

        next_node do |response|
          if calculator.state_benefits?
            question :how_many_nights_children_stay_with_payee?
          else
            question :gross_income_of_payee?
          end
        end
      end

      ## Q3
      money_question :gross_income_of_payee? do
        on_response do |response|
          calculator.income = response
        end

        next_node do
          case calculator.rate_type
          when :nil
            outcome :nil_rate_result
          when :flat
            outcome :flat_rate_result
          else
            question :how_many_other_children_in_payees_household?
          end
        end
      end

      ## Q4
      value_question :how_many_other_children_in_payees_household?, parse: Integer do
        on_response do |response|
          calculator.number_of_other_children = response
        end

        next_node do
          question :how_many_nights_children_stay_with_payee?
        end
      end

      ## Q5
      multiple_choice :how_many_nights_children_stay_with_payee? do
        option 0
        option 1
        option 2
        option 3
        option 4

        on_response do |response|
          calculator.number_of_shared_care_nights = response.to_i
        end

        calculate :child_maintenance_payment do
          sprintf("%.0f", calculator.calculate_maintenance_payment)
        end

        next_node do
          case calculator.rate_type
          when :nil
            outcome :nil_rate_result
          when :flat
            outcome :flat_rate_result
          else
            outcome :reduced_and_basic_rates_result
          end
        end
      end

      outcome :nil_rate_result

      outcome :flat_rate_result do
        precalculate :flat_rate_amount do
          sprintf('%.2f', calculator.base_amount)
        end
        precalculate :collect_fees do
          sprintf('%.2f', calculator.collect_fees)
        end
        precalculate :total_fees do
          sprintf('%.2f', calculator.total_fees(flat_rate_amount, collect_fees))
        end
        precalculate :total_yearly_fees do
          sprintf('%.2f', calculator.total_yearly_fees(collect_fees))
        end
      end

      outcome :reduced_and_basic_rates_result do
        precalculate :child_maintenance_payment do
          sprintf('%.2f', child_maintenance_payment)
        end
        precalculate :collect_fees do
          sprintf('%.2f', calculator.collect_fees_cmp(child_maintenance_payment))
        end
        precalculate :total_fees do
          sprintf('%.2f', calculator.total_fees_cmp(child_maintenance_payment, collect_fees))
        end
        precalculate :total_yearly_fees do
          sprintf('%.2f', calculator.total_yearly_fees(collect_fees))
        end
      end
    end
  end
end
