module SmartAnswer
  class CalculateMarriedCouplesAllowanceFlow < Flow
    def define
      content_id "e04dc5fe-9a31-4229-9de9-884dd0c0a8ce"
      name 'calculate-married-couples-allowance'
      status :published
      satisfies_need "101007"

      multiple_choice :were_you_or_your_partner_born_on_or_before_6_april_1935? do
        option :yes
        option :no

        calculate :is_before_april_changes do
          nil
        end
        calculate :gross_pension_contributions do
          nil
        end
        calculate :net_pension_contributions do
          nil
        end

        calculate :age_related_allowance_chooser do
          rates = Calculators::RatesQuery.from_file('married_couples_allowance').rates
          AgeRelatedAllowanceChooser.new(
            personal_allowance: rates.personal_allowance,
            over_65_allowance: rates.over_65_allowance,
            over_75_allowance: rates.over_75_allowance
          )
        end

        calculate :calculator do
          Calculators::MarriedCouplesAllowanceCalculator.new
        end

        next_node do |response|
          case response
          when 'yes'
            question :did_you_marry_or_civil_partner_before_5_december_2005?
          when 'no'
            outcome :sorry
          end
        end
      end

      multiple_choice :did_you_marry_or_civil_partner_before_5_december_2005? do
        option :yes
        option :no

        calculate :income_measure do |response|
          case response
          when 'yes'
            "husband"
          when 'no'
            "highest earner"
          else
            raise SmartAnswer::InvalidResponse
          end
        end

        next_node do |response|
          case response
          when 'yes'
            question :whats_the_husbands_date_of_birth?
          when 'no'
            question :whats_the_highest_earners_date_of_birth?
          end
        end
      end

      date_question :whats_the_husbands_date_of_birth? do
        from { Date.today.end_of_year }
        to { Date.parse('1 Jan 1896') }

        save_input_as :birth_date
        next_node do
          question :whats_the_husbands_income?
        end
      end

      date_question :whats_the_highest_earners_date_of_birth? do
        to { Date.parse('1 Jan 1896') }
        from { Date.today.end_of_year }

        save_input_as :birth_date
        next_node do
          question :whats_the_highest_earners_income?
        end
      end

      money_question :whats_the_husbands_income? do
        save_input_as :income

        validate { |response| response > 0 }

        next_node do |response|
          limit = (is_before_april_changes ? 26100.0 : 27000.0)
          if response.to_f >= limit
            question :paying_into_a_pension?
          else
            outcome :husband_done
          end
        end
      end

      money_question :whats_the_highest_earners_income? do
        save_input_as :income

        validate { |response| response > 0 }

        next_node do |response|
          limit = (is_before_april_changes ? 26100.0 : 27000.0)
          if response.to_f >= limit
            question :paying_into_a_pension?
          else
            outcome :highest_earner_done
          end
        end
      end

      multiple_choice :paying_into_a_pension? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            question :how_much_expected_contributions_before_tax?
          when 'no'
            question :how_much_expected_gift_aided_donations?
          end
        end
      end

      money_question :how_much_expected_contributions_before_tax? do
        save_input_as :gross_pension_contributions

        next_node do
          question :how_much_expected_contributions_with_tax_relief?
        end
      end

      money_question :how_much_expected_contributions_with_tax_relief? do
        save_input_as :net_pension_contributions

        next_node do
          question :how_much_expected_gift_aided_donations?
        end
      end

      money_question :how_much_expected_gift_aided_donations? do
        calculate :income do |response|
          calculator.calculate_adjusted_net_income(income.to_f, (gross_pension_contributions.to_f || 0), (net_pension_contributions.to_f || 0), response)
        end

        next_node do
          if income_measure == "husband"
            outcome :husband_done
          else
            outcome :highest_earner_done
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
