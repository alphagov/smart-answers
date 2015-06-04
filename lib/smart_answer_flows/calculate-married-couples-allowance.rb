module SmartAnswer
  class CalculateMarriedCouplesAllowanceFlow < Flow
    def define
      name 'calculate-married-couples-allowance'
      status :published
      satisfies_need "101007"

      multiple_choice :were_you_or_your_partner_born_on_or_before_6_april_1935? do
        option yes: :did_you_marry_or_civil_partner_before_5_december_2005?
        option no: :sorry

        calculate :age_related_allowance_chooser do
          rates = SmartAnswer::Calculators::RatesQuery.new('married_couples_allowance').rates
          AgeRelatedAllowanceChooser.new(
            personal_allowance: rates.personal_allowance,
            over_65_allowance: rates.over_65_allowance,
            over_75_allowance: rates.over_75_allowance
          )
        end

        calculate :calculator do
          Calculators::MarriedCouplesAllowanceCalculator.new(validate_income: false)
        end

      end

      multiple_choice :did_you_marry_or_civil_partner_before_5_december_2005? do
        option yes: :whats_the_husbands_date_of_birth?
        option no: :whats_the_highest_earners_date_of_birth?

        calculate :income_measure do |response|
          case response
          when 'yes' then "husband"
          when 'no' then "highest earner"
          else
            raise SmartAnswer::InvalidResponse
          end
        end
      end

      date_question :whats_the_husbands_date_of_birth? do
        from { Date.today.end_of_year }
        to { Date.parse('1 Jan 1896') }

        save_input_as :birth_date
        next_node :whats_the_husbands_income?
      end

      date_question :whats_the_highest_earners_date_of_birth? do
        to { Date.parse('1 Jan 1896') }
        from { Date.today.end_of_year }

        save_input_as :birth_date
        next_node :whats_the_highest_earners_income?
      end

      money_question :whats_the_husbands_income? do
        save_input_as :income

        validate { |response| response > 0 }

        next_node do |response|
          limit = (is_before_april_changes ? 26100.0 : 27000.0)
          if response.to_f >= limit
            :paying_into_a_pension?
          else
            :husband_done
          end
        end
      end

      money_question :whats_the_highest_earners_income? do
        save_input_as :income

        validate { |response| response > 0 }

        next_node do |response|
          limit = (is_before_april_changes ? 26100.0 : 27000.0)
          if response.to_f >= limit
            :paying_into_a_pension?
          else
            :highest_earner_done
          end
        end
      end

      multiple_choice :paying_into_a_pension? do
        option yes: :how_much_expected_contributions_before_tax?
        option no: :how_much_expected_gift_aided_donations?
      end

      money_question :how_much_expected_contributions_before_tax? do
        save_input_as :gross_pension_contributions

        next_node :how_much_expected_contributions_with_tax_relief?
      end

      money_question :how_much_expected_contributions_with_tax_relief? do
        save_input_as :net_pension_contributions

        next_node :how_much_expected_gift_aided_donations?
      end

      money_question :how_much_expected_gift_aided_donations? do
        calculate :income do |response|
          calculator.calculate_adjusted_net_income(income.to_f, (gross_pension_contributions.to_f || 0), (net_pension_contributions.to_f || 0), response)
        end

        next_node do |response|
          if income_measure == "husband"
            :husband_done
          else
            :highest_earner_done
          end
        end
      end

      outcome :husband_done do
        precalculate :allowance do
          age_related_allowance = age_related_allowance_chooser.get_age_related_allowance(birth_date)
          calculator.calculate_allowance(age_related_allowance, income)
        end
      end
      outcome :highest_earner_done do
        precalculate :allowance do
          age_related_allowance = age_related_allowance_chooser.get_age_related_allowance(birth_date)
          calculator.calculate_allowance(age_related_allowance, income)
        end
      end
      outcome :sorry
    end
  end
end

