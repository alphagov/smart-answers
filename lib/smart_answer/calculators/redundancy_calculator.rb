# -*- coding: utf-8 -*-
include ActionView::Helpers::NumberHelper

module SmartAnswer::Calculators
  class RedundancyCalculator
    def pay(age, years, weekly_pay)
      ratio_lookup = {
        "over-41" => 1.5,
        "22-40" => 1.0,
        "under-22" => 0.5
      }
      [430.00, weekly_pay.to_f].min * (years.to_f.floor * ratio_lookup[age])
    end

    def format_money(amount)
      formatted_amount = number_to_currency(amount, :precision => 2, :locale => :gb, :unit => "")
      formatted_amount.sub(".00", "")
    end
  end
end
