module SmartAnswer::Calculators
  class ChildMaintenanceCalculator
    include ActiveModel::Model

    attr_accessor :number_of_children
    attr_accessor :benefits
    attr_accessor :paying_or_receiving

    attr_accessor :income, :number_of_other_children, :number_of_shared_care_nights

    SCHEME_BASE_AMOUNT = 7.00
    REDUCED_RATE_THRESHOLD = 100
    BASIC_PLUS_RATE_THRESHOLD = 800
    SHARED_CARE_MAX_RELIEF_EXTRA_AMOUNT = 7.00
    SCHEME_MAX_INCOME = 3000

    STATE_BENEFITS = {
      income_support: "Income Support",
      ib_jobseekers_allowance: "income-based Jobseeker’s Allowance",
      employment_support_allowance: "income-related Employment and Support Allowance",
      pension_credit: "Pension Credit",
      cb_jobseekers_allowance: "contribution-based Jobseeker’s Allowance",
      cb_employment_support_llowance: "contribution-based Employment and Support Allowance",
      state_pension: "State Pension",
      incapacity_benefit: "Incapacity Benefit",
      training_allowance: "Training Allowance",
      armed_forces_compensation_scheme_payments: "Armed Forces Compensation Scheme payments",
      war_disablement_pension: "War Disablement Pension",
      bereavement_allowance: "Bereavement Allowance",
      carers_allowance: "Carer’s Allowance",
      maternity_allowance: "Maternity Allowance",
      severe_disablement_allowance: "Severe Disablement Allowance",
      industrial_injuries_disablement_benefit: "Industrial Injuries Disablement Benefit",
      widowed_parents_allowance: "Widowed Parent’s Allowance",
      widows_pension: "Widow’s pension",
      universal_credit_no_earned_income: "Universal Credit with no earned income",
      skillseekers_training: "Skillseekers training",
      war_partner_pension: "War Widow’s, Widower’s or Surviving Civil Partner’s Pension"
    }.freeze
    private_constant :STATE_BENEFITS

    def initialize(attributes = {})
      super
      @calculator_data = self.class.child_maintenance_data
    end

    # called after we enter income (we know benefits == no)
    def rate_type
      if state_benefits?
        if @number_of_shared_care_nights.positive?
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
      return 0 if state_benefits? #irrelevant what we return, with benefits rate is either nil or flat
      send("calculate_#{rate_type}_rate_payment")
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

    def receiving?
      @paying_or_receiving == "receive"
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

    def state_benefits
      STATE_BENEFITS
    end

    def state_benefits?
      ListValidator.new(state_benefits.keys).all_valid?(benefits.map(&:to_sym))
    end
  end
end
