module SmartAnswer::Calculators
  class ChildBenefitTaxCalculator
    attr_accessor :children_count,
                  :tax_year,
                  :part_year_children_count,
                  :income_details,
                  :allowable_deductions,
                  :other_allowable_deductions,
                  :part_year_claim_dates,
                  :child_index

    NET_INCOME_THRESHOLD = 50_000
    TAX_COMMENCEMENT_DATE = Date.parse("7 Jan 2013") # special case for 2012-13, only weeks from 7th Jan 2013 are taxable

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

      @child_benefit_data = self.class.child_benefit_data
      @part_year_claim_dates = HashWithIndifferentAccess.new
      @child_index = 0
    end

    def self.tax_years
      child_benefit_data.each_with_object([]) do |(key), tax_year|
        tax_year << key
      end
    end

    def benefits_claimed_amount
      no_of_full_year_children = @children_count - @part_year_children_count
      first_child_calculated = false
      total_benefit_amount = 0

      if no_of_full_year_children.positive?
        no_of_weeks = total_number_of_mondays(child_benefit_start_date, child_benefit_end_date)
        no_of_additional_children = no_of_full_year_children - 1
        total_benefit_amount = first_child_rate_total(no_of_weeks) + additional_child_rate_total(no_of_weeks, no_of_additional_children)
        first_child_calculated = true
      end

      if @part_year_claim_dates.count.positive?
        first_child = 0

        @part_year_claim_dates.values.each_with_index do |child, index|
          start_date = if (child[:start_date] < child_benefit_start_date) || ((@tax_year == 2012) && (child[:start_date] < TAX_COMMENCEMENT_DATE))
                         child_benefit_start_date
                       else
                         child[:start_date]
                       end

          end_date = if child[:end_date].nil?
                       child_benefit_end_date
                     else
                       child[:end_date]
                     end

          no_of_weeks = total_number_of_mondays(start_date, end_date)

          total_benefit_amount = if index.equal?(first_child) && (first_child_calculated == false)
                                   total_benefit_amount + first_child_rate_total(no_of_weeks)
                                 else
                                   total_benefit_amount + additional_child_rate_total(no_of_weeks, 1)
                                 end
        end
      end
      total_benefit_amount.to_f
    end

    def nothing_owed?
      calculate_adjusted_net_income < NET_INCOME_THRESHOLD || tax_estimate.abs.zero?
    end

    def tax_estimate
      (benefits_claimed_amount * (percent_tax_charge / 100.0)).floor
    end

    def percent_tax_charge
      if calculate_adjusted_net_income >= 60_000
        100
      elsif (59_900..59_999).cover?(calculate_adjusted_net_income)
        99
      else
        ((calculate_adjusted_net_income - 50_000) / 100.0).floor
      end
    end

    def calculate_adjusted_net_income
      (@income_details.to_f - (@allowable_deductions.to_f * 1.25) - @other_allowable_deductions.to_f)
    end

    def first_child_rate_total(no_of_weeks)
      selected_tax_year["first_child"] * no_of_weeks
    end

    def additional_child_rate_total(no_of_weeks, no_of_children)
      selected_tax_year["additional_child"] * no_of_children * no_of_weeks
    end

    def total_number_of_mondays(child_benefit_start_date, child_benefit_end_date)
      (child_benefit_start_date..child_benefit_end_date).count(&:monday?)
    end

    def child_benefit_start_date
      @tax_year.to_i == 2012 ? TAX_COMMENCEMENT_DATE : selected_tax_year["start_date"]
    end

    def child_benefit_end_date
      selected_tax_year["end_date"]
    end

    def selected_tax_year
      @child_benefit_data[@tax_year]
    end

    def self.child_benefit_data
      @child_benefit_data ||= YAML.load_file(Rails.root.join("config/smart_answers/rates/child_benefit_rates.yml")).with_indifferent_access
    end

    # Methods only used in calculator flow
    def store_date(date_type, response)
      @part_year_claim_dates[child_index] = if @part_year_claim_dates[child_index].nil?
                                              { date_type => response }
                                            else
                                              @part_year_claim_dates[child_index].merge!({ date_type => response })
                                            end
    end

    def valid_number_of_children?
      @children_count.positive? && @children_count <= 30
    end

    def valid_number_of_part_year_children?
      @part_year_children_count.positive? && @part_year_children_count <= @children_count
    end

    def valid_within_tax_year?(date_type)
      @part_year_claim_dates[@child_index][date_type] >= selected_tax_year["start_date"] && @part_year_claim_dates[@child_index][date_type] <= child_benefit_end_date
    end

    def valid_end_date?
      @part_year_claim_dates[@child_index][:end_date] > @part_year_claim_dates[@child_index][:start_date]
    end

    # Methods only used in results view
    def tax_year_label
      end_date = @child_benefit_data[@tax_year][:end_date]
      "#{tax_year} to #{end_date.year}"
    end

    def sa_register_deadline
      end_date = @child_benefit_data[@tax_year][:end_date]
      "5 October #{end_date.year}"
    end

    def tax_year_incomplete?
      end_date = @child_benefit_data[@tax_year][:end_date]
      end_date >= Time.zone.today
    end
  end
end
