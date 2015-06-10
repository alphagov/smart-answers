module SmartAnswer::Calculators
  class ChildcareCostCalculator
    # C1, C2, C4, C8, C9
    def self.weekly_cost(annual_cost)
      (Float(annual_cost) / 52.0).ceil
    end

    # C3, C7
    def self.weekly_cost_from_monthly(monthly_cost)
      weekly_cost(monthly_cost * 12.0)
    end

    # C5
    def self.weekly_cost_from_fortnightly(fortnightly_cost)
      (fortnightly_cost / 2.0).ceil
    end

    # C6
    def self.weekly_cost_from_four_weekly(four_weekly_cost)
      (four_weekly_cost / 4.0).ceil
    end

    # C10
    def self.cost_change(new_weekly_cost, old_weekly_tax)
      # all childcare costs are always rounded up to the nearest pound before calculations
      (Float(new_weekly_cost) - Float(old_weekly_tax).ceil)
    end
  end
end
