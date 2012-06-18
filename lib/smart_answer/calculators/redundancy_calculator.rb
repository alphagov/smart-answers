module SmartAnswer::Calculators
  class RedundancyCalculator

    def pay(age, years, weekly_pay)
      ratio_lookup = {
        "over-41" => 1.5,
        "22-41" => 1.0,
        "under-22" => 0.5
      }
      [430.00, weekly_pay.to_f].min * (years.to_f.floor * ratio_lookup[age])
    end
  end
end
