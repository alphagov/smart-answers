module SmartAnswer::Calculators
  class ChildMaintenanceCalculator
    attr_accessor :income, :number_of_other_children, :number_of_shared_care_nights

    SCHEME_BASE_AMOUNT = 7.00
    REDUCED_RATE_THRESHOLD = 100
    BASIC_PLUS_RATE_THRESHOLD = 800
    SHARED_CARE_MAX_RELIEF_EXTRA_AMOUNT = 7.00
    SCHEME_MAX_INCOME = 3000

    def initialize(number_of_children, benefits, paying_or_receiving)
      @number_of_children = number_of_children.to_i
      @benefits = benefits
      @paying_or_receiving = paying_or_receiving
      @calculator_data = self.class.child_maintenance_data
    end

    # called after we enter income (we know benefits == no)
    def rate_type
      if @benefits == 'yes'
        if @number_of_shared_care_nights > 0
          :nil
        else
          :flat
        end
      else
        # work out the rate based on income
        @calculator_data[:rates].find { |r| capped_income <= r[:max] }[:rate]
      end
    end

    def calculate_maintenance_payment
      if @benefits == 'no'
        send("calculate_#{rate_type}_rate_payment")
      else
        0 #irrelevant what we return, with benefits rate is either nil or flat
      end
    end

    def calculate_reduced_rate_payment
      reduced_rate = ((@income - REDUCED_RATE_THRESHOLD) * reduced_rate_multiplier) + base_amount
      reduced_rate_decreased = (reduced_rate - (reduced_rate * shared_care_multiplier)).round(0)
      if shared_care_multiplier == 0.5
        reduced_rate_decreased = reduced_rate_decreased - (@number_of_children * SHARED_CARE_MAX_RELIEF_EXTRA_AMOUNT)
      end
      #reduced rate can never be less than 7 pounds
      reduced_rate_decreased > SCHEME_BASE_AMOUNT ? reduced_rate_decreased : SCHEME_BASE_AMOUNT
    end

    def calculate_basic_rate_payment
      basic_rate = capped_income - (capped_income * relevant_other_child_multiplier)
      basic_rate = (basic_rate * basic_rate_multiplier)
      basic_rate_decreased = (basic_rate - (basic_rate * shared_care_multiplier)).round(0)
      # for maximum shared care relief, subtract additional £7 per child
      if shared_care_multiplier == 0.5
        basic_rate_decreased = basic_rate_decreased - (@number_of_children * SHARED_CARE_MAX_RELIEF_EXTRA_AMOUNT)
      end
      #basic rate can never be less than 7 pounds
      basic_rate_decreased > SCHEME_BASE_AMOUNT ? basic_rate_decreased : SCHEME_BASE_AMOUNT
    end

    #only used in the 2012 scheme
    def calculate_basic_plus_rate_payment
      basic_plus_rate = capped_income - (capped_income * relevant_other_child_multiplier)
      basic_qualifying_child_amount = (BASIC_PLUS_RATE_THRESHOLD * basic_rate_multiplier)
      additional_qualifying_child_amount = ((basic_plus_rate - BASIC_PLUS_RATE_THRESHOLD) * basic_plus_rate_multiplier)
      child_amounts_total = basic_qualifying_child_amount + additional_qualifying_child_amount
      total = (child_amounts_total - (child_amounts_total * shared_care_multiplier))
      if shared_care_multiplier == 0.5
        total = total - (@number_of_children * SHARED_CARE_MAX_RELIEF_EXTRA_AMOUNT)
      end
      total.round(2)
    end

    def reduced_rate_multiplier
      matrix = @calculator_data[:reduced_rate_multipliers]
      matrix[number_of_other_children_index][number_of_qualifying_children_index]
    end

    def basic_rate_multiplier
      matrix = @calculator_data[:basic_rate_multipliers]
      matrix[number_of_qualifying_children_index]
    end

    def shared_care_multiplier
      @calculator_data[:shared_care_reductions][@number_of_shared_care_nights]
    end

    def relevant_other_child_multiplier
      @calculator_data[:relevant_other_child_reductions][number_of_other_children_index]
    end

    def basic_plus_rate_multiplier
      @calculator_data[:basic_plus_rate_multipliers][number_of_qualifying_children_index]
    end

    # never use more than the net (or gross) income maximum in calculations
    def capped_income
      max_income = SCHEME_MAX_INCOME
      @income > max_income ? max_income : @income
    end

    def number_of_other_children_index
      @number_of_other_children > 3 ? 3 : @number_of_other_children
    end

    def number_of_qualifying_children
      @number_of_children > 3 ? 3 : @number_of_children
    end

    def number_of_qualifying_children_index
      number_of_qualifying_children - 1
    end

    def base_amount
      SCHEME_BASE_AMOUNT
    end

    def paying?
      @paying_or_receiving == "pay"
    end

    def collect_fees
      if paying?
        (base_amount * 0.2).round(2)
      else
        (base_amount * 0.04).round(2)
      end
    end

    def collect_fees_cmp(child_maintenance_payment)
      child_maintenance_payment = child_maintenance_payment.to_f
      if paying?
        (child_maintenance_payment * 0.2).round(2)
      else
        (child_maintenance_payment * 0.04).round(2)
      end
    end

    def total_fees(flat_rate_amount, collect_fees)
      flat_rate_amount = flat_rate_amount.to_f
      collect_fees = collect_fees.to_f
      if paying?
        (flat_rate_amount + collect_fees).round(2)
      else
        (flat_rate_amount - collect_fees).round(2)
      end
    end

    def total_fees_cmp(child_maintenance_payment, collect_fees)
      child_maintenance_payment = child_maintenance_payment.to_f
      collect_fees = collect_fees.to_f
      if paying?
        (child_maintenance_payment + collect_fees).round(2)
      else
        (child_maintenance_payment - collect_fees).round(2)
      end
    end

    def total_yearly_fees(collect_fees)
      collect_fees = collect_fees.to_f
      (collect_fees * 52).round(2)
    end

    def self.child_maintenance_data
      @child_maintenance_data ||= YAML.load_file(Rails.root.join("lib/data/child_maintenance_data.yml"))
    end
  end
end
