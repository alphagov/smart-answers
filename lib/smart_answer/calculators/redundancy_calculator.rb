# -*- coding: utf-8 -*-
include ActionView::Helpers::NumberHelper

module SmartAnswer::Calculators
  class RedundancyCalculator
    def pay(age, years, weekly_pay)
      pay = 0
      age = age.to_i
      years = [20, years.to_i].min
      
      (1..years.to_i).each do |i|
        pay += ([430.00, weekly_pay.to_f].min * ratio(age))
        age -= 1 
      end
      pay
    end

    def ratio(age)
      return 0.5 if (0..22).include?(age)
      return 1.0 if (23..41).include?(age)
      return 1.5 if (42..1000).include?(age)
    end

    def format_money(amount)
      formatted_amount = number_to_currency(amount, :precision => 2, :locale => :gb, :unit => "")
      formatted_amount.sub(".00", "")
    end
  end
end
