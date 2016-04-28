module SmartAnswer::Calculators
  class MarriedCouplesAllowanceCalculator
    def calculate_adjusted_net_income(income, gross_pension_contributions, net_pension_contributions, gift_aided_donations)
      income - gross_pension_contributions - (net_pension_contributions * 1.25) - (gift_aided_donations * 1.25)
    end

    def calculate_allowance(age_related_allowance, income)
      income = 1 if income < 1

      mca_entitlement = maximum_mca

      if income > income_limit_for_personal_allowances
        attempted_reduction = (income - income_limit_for_personal_allowances) / 2

        # \/ this reduction actually applies across the board for personal allowances,
        # but extracting that was more than required for this piece of work. Please see
        # note in AgeRelatedAllowanceChooser
        maximum_reduction_of_allowances = age_related_allowance - personal_allowance
        remaining_reduction = attempted_reduction - maximum_reduction_of_allowances

        if remaining_reduction > 0
          reduced_mca = maximum_mca - remaining_reduction
          if reduced_mca > minimum_mca
            mca_entitlement = reduced_mca
          else
            mca_entitlement = minimum_mca
          end
        else
          mca_entitlement = maximum_mca
        end
      end

      mca = mca_entitlement * 0.1
      SmartAnswer::Money.new(mca)
    end

    def maximum_mca
      rates.maximum_married_couple_allowance
    end

    def minimum_mca
      rates.minimum_married_couple_allowance
    end

    def income_limit_for_personal_allowances
      rates.income_limit_for_personal_allowances
    end

    def personal_allowance
      rates.personal_allowance
    end

    def rates
      @rates ||= RatesQuery.from_file('married_couples_allowance').rates
    end
  end
end
