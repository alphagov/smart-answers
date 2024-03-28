module SmartAnswer::Calculators
  class ChildBenefitTaxCalculator
    attr_accessor :children_count,
                  :tax_year,
                  :part_year_children_count,
                  :income_details,
                  :allowable_deductions,
                  :other_allowable_deductions,
                  :part_year_claim_dates,
                  :child_number

    attr_reader :child_benefit_rates

    TAX_COMMENCEMENT_DATE = Date.parse("7 Jan 2013") # special case for 2012-13, only weeks from 7th Jan 2013 are taxable
    MAX_CHILDREN = 30

    def initialize(children_count: 0,
                   tax_year: nil,
                   part_year_children_count: 0,
                   income_details: 0,
                   allowable_deductions: 0,
                   other_allowable_deductions: 0)

      @children_count = children_count
      @tax_year = tax_year
      @part_year_children_count = part_year_children_count
      @income_details = income_details
      @allowable_deductions = allowable_deductions
      @other_allowable_deductions = other_allowable_deductions

      @part_year_claim_dates = HashWithIndifferentAccess.new
      @child_number = 1
      @child_benefit_rates = self.class.child_benefit_rates
    end

    def self.tax_years
      child_benefit_rates.each_with_object([]) do |(key), tax_year|
        tax_year.unshift(key)
      end
    end

    def self.child_benefit_rates
      @child_benefit_rates ||= YAML.load_file(
        Rails.root.join("config/smart_answers/rates/child_benefit_rates.yml"),
        permitted_classes: [Date, Symbol],
      ).with_indifferent_access
    end

    def benefits_claimed_amount
      no_of_full_year_children = children_count - part_year_children_count
      total_benefit_amount = 0

      if no_of_full_year_children.positive?
        child_benefit_days = (child_benefit_start_date..child_benefit_end_date).to_a
        no_of_weeks = child_benefit_days.select(&:monday?).count
        no_of_additional_children = no_of_full_year_children - 1
        additional_children_rate = additional_children_rate_total(no_of_weeks * no_of_additional_children)
        total_benefit_amount += (only_child_rate_total(no_of_weeks) + additional_children_rate)
        only_child_calculated = true
      end

      if part_year_claim_dates.count.positive?
        part_year_claim_dates.each_value do |child|
          child[:end_date] = child[:end_date] || child_benefit_end_date

          if (tax_year == "2012") && (child[:start_date] < TAX_COMMENCEMENT_DATE)
            child[:start_date] = child_benefit_start_date
          end
        end

        total_benefit_amount += partial_child_benefit(only_child_calculated)
      end

      total_benefit_amount.to_f
    end

    def tax_estimate
      (benefits_claimed_amount * (percent_tax_charge / 100.0)).floor
    end

    def percent_tax_charge
      # the percentage tax charge applies above the lower earnings threshold and the percentage
      # is relative to the earnings position between the lower and upper thresholds
      # for every full percent of the difference above the threshold. E.g. If the difference between the upper and lower
      # thresholds is £1000 then each £10 increment above the lower threshold will be an extra percentage of tax
      lower_earnings_threshold = child_benefit_rates[tax_year][:lower_earnings_threshold]
      upper_earnings_threshold = child_benefit_rates[tax_year][:upper_earnings_threshold]
      difference_between_thresholds = upper_earnings_threshold - lower_earnings_threshold
      adjusted_net_income = calculate_adjusted_net_income

      if adjusted_net_income < lower_earnings_threshold
        0
      elsif adjusted_net_income >= upper_earnings_threshold
        100
      else
        (((adjusted_net_income - lower_earnings_threshold) / difference_between_thresholds) * 100.0).floor
      end
    end

    def calculate_adjusted_net_income
      (income_details.to_f - (allowable_deductions.to_f * 1.25) - other_allowable_deductions.to_f)
    end

    # Methods only used in calculator flow
    def store_date(date_type, response)
      part_year_claim_dates[child_number] = if part_year_claim_dates[child_number].nil?
                                              { date_type => response }
                                            else
                                              part_year_claim_dates[child_number].merge!({ date_type => response })
                                            end
    end

    def valid_number_of_children?
      children_count.positive? && children_count <= MAX_CHILDREN
    end

    def valid_number_of_part_year_children?
      part_year_children_count.positive? && part_year_children_count <= children_count
    end

    def valid_within_tax_year?(date_type)
      part_year_claim_dates[child_number][date_type] >= selected_tax_year["start_date"] &&
        part_year_claim_dates[child_number][date_type] <= child_benefit_end_date
    end

    def valid_end_date?
      part_year_claim_dates[child_number][:end_date] > part_year_claim_dates[child_number][:start_date]
    end

    # Methods only used in results view
    def tax_year_label
      end_date = child_benefit_rates[tax_year][:end_date]
      "#{tax_year} to #{end_date.year}"
    end

    def sa_register_deadline
      end_date = child_benefit_rates[tax_year][:end_date]
      "5 October #{end_date.year}"
    end

    def tax_year_incomplete?
      end_date = child_benefit_rates[tax_year][:end_date]
      end_date >= Time.zone.today
    end

  private

    def partial_child_benefit(only_child_calculated)
      benefit_mondays = part_year_claim_dates.values.flat_map do |dates|
        (dates[:start_date]..dates[:end_date]).select(&:monday?)
      end

      if only_child_calculated
        additional_children_rate_total(benefit_mondays.count)
      else
        only_child_weeks = benefit_mondays.uniq.count
        additional_children_weeks = benefit_mondays.count - only_child_weeks

        only_child_rate_total(only_child_weeks) + additional_children_rate_total(additional_children_weeks)
      end
    end

    def only_child_rate_total(no_of_weeks)
      selected_tax_year["only_child"] * no_of_weeks
    end

    def additional_children_rate_total(no_of_weeks)
      selected_tax_year["additional_child"] * no_of_weeks
    end

    def child_benefit_start_date
      tax_year.to_i == 2012 ? TAX_COMMENCEMENT_DATE : selected_tax_year["start_date"]
    end

    def child_benefit_end_date
      selected_tax_year["end_date"]
    end

    def selected_tax_year
      child_benefit_rates[tax_year]
    end
  end
end
