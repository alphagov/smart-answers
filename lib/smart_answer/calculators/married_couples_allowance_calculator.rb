module SmartAnswer::Calculators
  class MarriedCouplesAllowanceCalculator
    attr_accessor :marriage_or_civil_partnership_before_5_december_2005

    def initialize
      @personal_allowance_calculator = PersonalAllowanceCalculator.new
    end

    def income_measure
      case marriage_or_civil_partnership_before_5_december_2005
      when 'yes'
        "husband"
      when 'no'
        "highest earner"
      end
    end

    def calculate_adjusted_net_income(income, gross_pension_contributions, net_pension_contributions, gift_aided_donations)
      income - gross_pension_contributions - (net_pension_contributions * 1.25) - (gift_aided_donations * 1.25)
    end

    def calculate_allowance(birth_date, income)
      income = 1 if income < 1

      mca_entitlement = maximum_mca

      if income > income_limit_for_personal_allowances
        attempted_reduction = (income - income_limit_for_personal_allowances) / 2

        # \/ this reduction actually applies across the board for personal allowances,
        # but extracting that was more than required for this piece of work. Please see
        # note in PersonalAllowanceCalculator
        maximum_reduction_of_allowances = age_related_allowance(birth_date) - personal_allowance
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
      married_couples_allowance_rates.maximum_married_couple_allowance
    end

    def minimum_mca
      married_couples_allowance_rates.minimum_married_couple_allowance
    end

    def income_limit_for_personal_allowances
      @personal_allowance_calculator.income_limit_for_personal_allowances
    end

    def personal_allowance
      @personal_allowance_calculator.personal_allowance
    end

    def age_related_allowance(birth_date)
      @personal_allowance_calculator.get_age_related_allowance(birth_date)
    end

    def married_couples_allowance_rates
      @married_couples_allowance_rates ||= RatesQuery.from_file('married_couples_allowance').rates
    end
  end
end
