require 'ostruct'

module SmartAnswer::Calculators
  class ChildBenefitTaxCalculator < OpenStruct
    def benefit_claimed_weeks
      ((child_benefit_end_date - child_benefit_start_date)/7.0).round
    end

    def benefit_taxable_weeks
      h_date = Date.new(2013, 1, 7)
      if child_benefit_end_date < h_date
        0
      else
        ((child_benefit_end_date - h_date)/7.0).round
      end
    end

    def weekly_amount
      first_child = SmartAnswer::Money.new 20.30
      additional_child = SmartAnswer::Money.new 13.40

      first_child + additional_child*(children_claiming - 1)
    end

    def benefit_claimed_amount
      benefit_claimed_weeks * weekly_amount
    end

    def benefit_taxable_amount
      benefit_taxable_weeks * weekly_amount
    end

    def percent_tax_charge
      if income >= 60000
        100.0
      else
        (income - 50000)/100.0
      end
    end

    def benefit_tax
      a
      percent_tax_charge * benefit_taxable_amount / 100.0
    end
  end
end
