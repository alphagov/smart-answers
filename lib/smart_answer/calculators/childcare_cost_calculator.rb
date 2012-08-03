module SmartAnswer::Calculators
  class ChildcareCostCalculator
    # C1, C2, C4, C8, C9
    def self.weekly_cost(annual_cost)
      (annual_cost / 52.0).round
    end

    # C3, C7
    def self.weekly_cost_from_monthly(monthly_cost)
      weekly_cost(monthly_cost * 12.0)
    end

    # C5
    def self.weekly_cost_from_fortnightly(fortnightly_cost)
      (fortnightly_cost / 2.0).round
    end

    # C6
    def self.weekly_cost_from_four_weekly(four_weekly_cost)
      (four_weekly_cost / 4.0).round
    end

    # C10
    def self.cost_change(new_weekly_cost, old_weekly_tax)
      (new_weekly_cost - old_weekly_tax).abs
    end

    # C11, C12, C14
    def self.cost_change_annual(annual_cost, old_weekly_tax)
      cost_change(weekly_cost(annual_cost), old_weekly_tax)
    end

    # C13
    def self.cost_change_month(month_cost, old_weekly_tax)
      cost_change(weekly_cost_from_monthly(month_cost), old_weekly_tax)
    end
  end
end
