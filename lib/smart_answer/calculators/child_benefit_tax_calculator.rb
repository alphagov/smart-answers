require 'ostruct'

module SmartAnswer::Calculators
  class ChildBenefitTaxCalculator < OpenStruct
    def tax_introduction_date
      @tax_introduction_date = Date.new(2013, 1, 7)
    end

    def calculation
      @calculation ||= calculate_taxable_amounts
    end

    def benefit_tax
      percent_tax_charge * benefit_taxable_amount / 100.0
    end

    def calculate_taxable_amounts
      raise "Start of tax year, end of tax year and claim periods must be provided" if start_of_tax_year.nil? or end_of_tax_year.nil? or claim_periods.nil?

      weekly_benefit_amounts = children_claimed_for_by_week.inject({}) {|hash, (beginning_of_week,number_of_children)| hash.merge( beginning_of_week => weekly_amount(number_of_children) )}

      taxable_weeks = weekly_benefit_amounts.select {|beginning_of_week, amount| beginning_of_week >= tax_introduction_date }
      non_taxable_weeks = weekly_benefit_amounts.select {|beginning_of_week, amount| beginning_of_week < tax_introduction_date }

      taxable_amount = taxable_weeks.map {|k,v| v}.inject(:+) || 0
      non_taxable_amount = non_taxable_weeks.map {|k,v| v}.inject(:+) || 0

      OpenStruct.new(
        :benefit_taxable_amount => taxable_amount,
        :benefit_non_taxable_amount => non_taxable_amount
      )
    end

    def children_claimed_for_by_week
      weeks = (start_of_tax_year..end_of_tax_year).select {|d| d.cwday == 1 }

      claim_weeks = Hash.new([])
      weeks.each_with_index do |first_day_of_week|
        claim_weeks[first_day_of_week] = claim_periods.select {|period| period.cover?(first_day_of_week) }.size
      end

      claim_weeks
    end

    def weekly_amount(number_of_children)
      return 0 if number_of_children < 1

      first_child = SmartAnswer::Money.new 20.30
      additional_child = SmartAnswer::Money.new 13.40

      first_child + additional_child*(number_of_children - 1)
    end

    def percent_tax_charge
      raise "Income must be provided" if income.nil?

      if income >= 60000
        100.0
      else
        (income - 50000)/100.0
      end
    end

    def benefit_taxable_amount
      calculation.benefit_taxable_amount
    end

    def benefit_non_taxable_amount
      calculation.benefit_non_taxable_amount
    end

    def benefit_claimed_amount
      benefit_taxable_amount + benefit_non_taxable_amount
    end

    def formatted_benefit_claimed_amount
      format_money benefit_claimed_amount
    end

    def formatted_benefit_taxable_amount
      format_money benefit_taxable_amount
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
