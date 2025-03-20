module SmartAnswer::Calculators
  class MarriedCouplesAllowanceCalculator
    attr_accessor :marriage_or_civil_partnership_before_5_december_2005,
                  :birth_date,
                  :income,
                  :gross_pension_contributions,
                  :net_pension_contributions,
                  :gift_aided_donations

    def initialize
      @personal_allowance_calculator = PersonalAllowanceCalculator.new
    end

    def husband_income_measured?
      marriage_or_civil_partnership_before_5_december_2005 == "yes"
    end

    def income_within_limit_for_personal_allowance?
      income.to_f < income_limit_for_personal_allowances
    end

    def valid_income?
      income > 0 # rubocop:disable Style/NumericPredicate
    end

    def calculate_adjusted_net_income
      income.to_f - gross_pension_contributions.to_f - (net_pension_contributions.to_f * 1.25) - (gift_aided_donations.to_f * 1.25)
    end

    def calculate_allowance
      income = calculate_adjusted_net_income

      income = 1 if income < 1

      mca_entitlement = maximum_mca

      if income > income_limit_for_personal_allowances
        reduction = (income - income_limit_for_personal_allowances) / 2
        reduced_mca = maximum_mca - reduction
        mca_entitlement = if reduced_mca > minimum_mca
                            reduced_mca
                          else
                            minimum_mca
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

    delegate :income_limit_for_personal_allowances, to: :@personal_allowance_calculator

    delegate :personal_allowance, to: :@personal_allowance_calculator

    def married_couples_allowance_rates
      @married_couples_allowance_rates ||= RatesQuery.from_file("married_couples_allowance").rates
    end
  end
end
