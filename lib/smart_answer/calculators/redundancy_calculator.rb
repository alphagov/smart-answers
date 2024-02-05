module SmartAnswer::Calculators
  class RedundancyCalculator
    extend ActionView::Helpers::NumberHelper

    attr_reader :pay, :number_of_weeks_entitlement

    def initialize(rate, age, years, weekly_pay)
      @pay = @number_of_weeks_entitlement = 0
      age = age.to_i
      years = [20, years.to_i].min

      (1..years.to_i).each do
        entitlement_ratio = ratio(age)
        @pay += ([rate.to_f, weekly_pay.to_f].min * entitlement_ratio).round(10)
        @number_of_weeks_entitlement += entitlement_ratio
        age -= 1
      end
    end

    def ratio(age)
      case age
      when 0..22
        0.5
      when 23..41
        1.0
      when 42..1000
        1.5
      end
    end

    def format_money(amount)
      self.class.format_money(amount)
    end

    def self.format_money(amount)
      formatted_amount = number_to_currency(amount, precision: 2, locale: :gb, unit: "")
      formatted_amount.sub(".00", "")
    end

    def self.redundancy_rates(date)
      RatesQuery.from_file("redundancy_pay").rates(date)
    end

    def self.northern_ireland_redundancy_rates(date)
      RatesQuery.from_file("redundancy_pay_northern_ireland").rates(date)
    end

    # If you change these two functions, make sure to update
    # the config file and tests to ensure the right amount of
    # historical rates data is available.
    def self.first_selectable_date
      if between_january_and_august?
        four_years_ago
      else
        three_years_ago
      end
    end

    def self.last_selectable_date
      if between_january_and_august?
        end_of_current_year
      else
        end_of_next_year
      end
    end

    def self.between_january_and_august?
      Time.zone.today.month < 9
    end

    def self.four_years_ago
      4.years.ago.beginning_of_year
    end

    def self.three_years_ago
      3.years.ago.beginning_of_year
    end

    def self.end_of_current_year
      Time.zone.today.end_of_year
    end

    def self.end_of_next_year
      Time.zone.today.next_year.end_of_year
    end

    private_class_method :between_january_and_august?, :four_years_ago, :three_years_ago, :end_of_current_year, :end_of_next_year
  end
end
