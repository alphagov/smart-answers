module SmartAnswer::Calculators
  class RedundancyCalculator
    extend ActionView::Helpers::NumberHelper

    attr_reader :pay, :number_of_weeks_entitlement

    def initialize(rate, age, years, weekly_pay)
      @pay = @number_of_weeks_entitlement = 0
      age = age.to_i
      years = [20, years.to_i].min

      (1..years.to_i).each do |i|
        entitlement_ratio = ratio(age)
        @pay += ([rate.to_f, weekly_pay.to_f].min * entitlement_ratio).round(10)
        @number_of_weeks_entitlement += entitlement_ratio
        age -= 1
      end
    end

    def ratio(age)
      return 0.5 if (0..22).include?(age)
      return 1.0 if (23..41).include?(age)
      return 1.5 if (42..1000).include?(age)
    end

    def format_money(amount)
      self.class.format_money(amount)
    end

    def self.format_money(amount)
      formatted_amount = number_to_currency(amount, precision: 2, locale: :gb, unit: "")
      formatted_amount.sub(".00", "")
    end

    def self.redundancy_rates(date)
      RatesQuery.new('redundancy_pay').rates(date)
    end

    def self.northern_ireland_redundancy_rates(date)
      RatesQuery.new('redundancy_pay_northern_ireland').rates(date)
    end
  end
end
