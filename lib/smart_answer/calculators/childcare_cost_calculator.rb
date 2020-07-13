module SmartAnswer::Calculators
  class ChildcareCostCalculator
    attr_accessor :cost_change_4_weeks,
                  :weekly_cost,
                  :new_weekly_costs,
                  :old_weekly_costs,
                  :weekly_difference

    delegate :abs, to: :weekly_difference, prefix: true

    def initialize
      @cost_change_4_weeks = false
    end

    # C1, C2, C4, C8, C9
    def weekly_cost_from_annual(annual_cost)
      (Float(annual_cost) / 52.0).ceil
    end

    # C3, C7
    def weekly_cost_from_monthly(monthly_cost)
      weekly_cost_from_annual(monthly_cost * 12.0)
    end

    # C5
    def weekly_cost_from_fortnightly(fortnightly_cost)
      (fortnightly_cost / 2.0).ceil
    end

    # C6
    def weekly_cost_from_four_weekly(four_weekly_cost)
      (four_weekly_cost / 4.0).ceil
    end

    # C10
    def cost_change(new_weekly_cost, old_weekly_tax)
      # all childcare costs are always rounded up to the nearest pound before calculations
      (Float(new_weekly_cost) - Float(old_weekly_tax).ceil)
    end

    def ten_or_more
      weekly_difference_abs >= 10
    end

    def title_change_text
      weekly_difference >= 10 ? "increased" : "decreased"
    end

    def difference_money
      SmartAnswer::Money.new(weekly_difference_abs)
    end
  end
end
