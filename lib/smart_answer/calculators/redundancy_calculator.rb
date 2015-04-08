# -*- coding: utf-8 -*-
include ActionView::Helpers::NumberHelper

module SmartAnswer::Calculators
  class RedundancyCalculator

    AMOUNTS = [
      OpenStruct.new(start_date: Date.new(2012, 01, 01), end_date: Date.new(2013, 01, 31), max: "12,900", rate: 430),
      OpenStruct.new(start_date: Date.new(2013, 02, 01), end_date: Date.new(2014, 04, 05), max: "13,500", rate: 450),
      OpenStruct.new(start_date: Date.new(2014, 04, 06), end_date: Date.new(2015, 04, 05), max: "13,920", rate: 464),
      OpenStruct.new(start_date: Date.new(2015, 04, 06), end_date: Date.new(2130, 12, 31), max: "13,920", rate: 475)
    ]

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
      AMOUNTS.find { |r| r.start_date <= date and r.end_date >= date }
    end

  end
end
