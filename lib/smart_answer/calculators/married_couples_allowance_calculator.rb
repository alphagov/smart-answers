module SmartAnswer::Calculators
  class MarriedCouplesAllowanceCalculator
    attr_accessor :born_on_or_before_6_april_1935
    attr_accessor :marriage_or_civil_partnership_before_5_december_2005
    attr_accessor :birth_date
    attr_accessor :income
    attr_accessor :paying_into_a_pension
    attr_accessor :gross_pension_contributions
    attr_accessor :net_pension_contributions
    attr_accessor :gift_aided_donations

    def initialize
      @personal_allowance_calculator = PersonalAllowanceCalculator.new
    end

    def qualifies?
      born_on_or_before_6_april_1935 == "yes"
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

    def paying_into_a_pension?
      paying_into_a_pension == "yes"
    end

    def calculate_adjusted_net_income
      income.to_f - gross_pension_contributions.to_f - (net_pension_contributions.to_f * 1.25) - (gift_aided_donations.to_f * 1.25)
    end

    def calculate_allowance
      income = calculate_adjusted_net_income

      income = 1 if income < 1

      mca_entitlement = maximum_mca

      if income > income_limit_for_personal_allowances
        attempted_reduction = (income - income_limit_for_personal_allowances) / 2

        # \/ this reduction actually applies across the board for personal allowances,
        # but extracting that was more than required for this piece of work. Please see
        # note in PersonalAllowanceCalculator
        maximum_reduction_of_allowances = age_related_allowance(birth_date) - personal_allowance
        remaining_reduction = attempted_reduction - maximum_reduction_of_allowances

        if remaining_reduction > 0 # rubocop:disable Style/NumericPredicate
          reduced_mca = maximum_mca - remaining_reduction
          mca_entitlement = if reduced_mca > minimum_mca
                              reduced_mca
                            else
                              minimum_mca
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
      @personal_allowance_calculator.age_related_allowance(birth_date)
    end

    def married_couples_allowance_rates
      @married_couples_allowance_rates ||= RatesQuery.from_file("married_couples_allowance").rates
    end
  end
end
