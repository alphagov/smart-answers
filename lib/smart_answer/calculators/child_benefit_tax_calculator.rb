require 'ostruct'

module SmartAnswer::Calculators
  class ChildBenefitTaxCalculator < OpenStruct
    def benefit_claimed_weeks
      return 0 if child_benefit_end_date.nil? or child_benefit_start_date.nil?
      ((child_benefit_end_date - child_benefit_start_date)/7.0).round
    end

    def benefit_taxable_weeks
      return 0 if child_benefit_end_date.nil?
      if child_benefit_end_date <= Date.new(2013, 4, 6)
        ((child_benefit_end_date - Date.new(2013, 1, 7))/7.0).round
      else
        52
      end
    end

    def weekly_amount
      return 0 if children_claiming < 1

      first_child = SmartAnswer::Money.new 20.30
      additional_child = SmartAnswer::Money.new 13.40

      first_child + additional_child*(children_claiming - 1)
    end

    def benefit_claimed_amount
      benefit_claimed_weeks * weekly_amount
    end

    def formatted_benefit_claimed_amount
      format_money benefit_claimed_amount
    end

    def benefit_taxable_amount
      benefit_taxable_weeks * weekly_amount
    end

    def formatted_benefit_taxable_amount
      format_money benefit_taxable_amount
    end

    def percent_tax_charge
      if income >= 60000
        100.0
      else
        (income - 50000)/100.0
      end
    end

    def benefit_tax
      percent_tax_charge * benefit_taxable_amount / 100.0
    end

    def formatted_benefit_tax
      format_money benefit_tax
    end

    def format_money(value)
      # regex strips zeros
      str = sprintf("%.#{2}f", value).to_s.sub(/\.0+$/, '')
    end
  end
end
