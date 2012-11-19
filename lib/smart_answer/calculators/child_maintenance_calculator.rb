module SmartAnswer::Calculators
  class ChildMaintenanceCalculator
    
    attr_reader :calculation_scheme
    attr_accessor :income, :number_of_other_children, :number_of_shared_care_nights
    
    OLD_SCHEME_BASE_AMOUNT = 5
    NEW_SCHEME_BASE_AMOUNT = 5
    OLD_SCHEME_MINIMUM_REDUCED_BASIC = 5
    REDUCED_RATE_THRESHOLD = 100
    BASIC_PLUS_RATE_THRESHOLD = 800
    SHARED_CARE_MAX_RELIEF_EXTRA_AMOUNT = 7
    OLD_SCHEME_MAX_INCOME = 2000
    NEW_SCHEME_MAX_INCOME = 3000
    
    def initialize(number_of_children, calculation_scheme, benefits)
      @number_of_children = number_of_children.to_i
      @calculation_scheme = calculation_scheme
      @benefits = benefits
      load_calculator_data
    end
    
    # called after we enter income (we know benefits == no)
    def rate_type
      @calculator_data[:rates][@calculation_scheme].find { |r| capped_income <= r[:max] }[:rate]
    end

    # called when we know benefits == yes and we know shared care nights, but income is not set
    def rate_type_when_benefits
      if @number_of_shared_care_nights > 0
        :nil
      else
        :flat
      end
    end
    
    def calculate_maintenance_payment
      if @benefits == 'no'
        send("calculate_#{rate_type}_rate_payment")
      else
        0 # not used so doesn't matter
      end
    end
    
    def calculate_reduced_rate_payment
      reduced_rate = ((@income - REDUCED_RATE_THRESHOLD) * reduced_rate_multiplier) + base_amount
      reduced_rate_decreased = (reduced_rate - (reduced_rate * shared_care_multiplier)).round(0)
      if shared_care_multiplier == 0.5
        reduced_rate_decreased = reduced_rate_decreased - (@number_of_children * SHARED_CARE_MAX_RELIEF_EXTRA_AMOUNT)
      end
      #reduced rate can never be less than 5 pounds
      reduced_rate_decreased > OLD_SCHEME_MINIMUM_REDUCED_BASIC ? reduced_rate_decreased : OLD_SCHEME_MINIMUM_REDUCED_BASIC
    end
    
    def calculate_basic_rate_payment
      basic_rate = capped_income - (capped_income * relevant_other_child_multiplier)
      basic_rate = (basic_rate * basic_rate_multiplier)
      basic_rate_decreased = (basic_rate - (basic_rate * shared_care_multiplier)).round(0)
      # for maximum shared care relief, subtract additional £7 per child
      if shared_care_multiplier == 0.5
        basic_rate_decreased = basic_rate_decreased - (@number_of_children * SHARED_CARE_MAX_RELIEF_EXTRA_AMOUNT)
      end
      #basic rate can never be less than 5 pounds
      basic_rate_decreased > OLD_SCHEME_MINIMUM_REDUCED_BASIC ? basic_rate_decreased : OLD_SCHEME_MINIMUM_REDUCED_BASIC
    end
    
    #only used in the 2012 scheme
    def calculate_basic_plus_rate_payment
      basic_plus_rate = @income - (@income * relevant_other_child_multiplier)
      basic_qualifying_child_amount = (BASIC_PLUS_RATE_THRESHOLD * basic_rate_multiplier)
      additional_qualifying_child_amount = ((basic_plus_rate - BASIC_PLUS_RATE_THRESHOLD) * basic_plus_rate_multiplier)
      child_amounts_total = basic_qualifying_child_amount + additional_qualifying_child_amount
      (child_amounts_total - (child_amounts_total * shared_care_multiplier)).round(2)
    end
    
    def reduced_rate_multiplier
      matrix = @calculator_data[scheme_sym(:reduced_rate_multipliers)]
      matrix[number_of_other_children_index][number_of_qualifying_children_index]
    end
    
    def basic_rate_multiplier
      matrix = @calculator_data[scheme_sym(:basic_rate_multipliers)]
      matrix[number_of_qualifying_children_index]
    end
    
    def shared_care_multiplier
      @calculator_data[:shared_care_reductions][@number_of_shared_care_nights]
    end
    
    def relevant_other_child_multiplier
      @calculator_data[scheme_sym(:relevant_other_child_reductions)][number_of_other_children_index]
    end
    
    def basic_plus_rate_multiplier
      @calculator_data[:basic_plus_rate_multipliers][number_of_qualifying_children]
    end

    # never use more than the net (or gross) income maximum in calculations
    def capped_income
      max_income = ( @calculation_scheme == :old ? OLD_SCHEME_MAX_INCOME : NEW_SCHEME_MAX_INCOME )
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
      @calculation_scheme == :old ? OLD_SCHEME_BASE_AMOUNT : NEW_SCHEME_BASE_AMOUNT
    end
    
    def scheme_sym(sym)
      "#{@calculation_scheme.to_s}_#{sym.to_s}".to_sym
    end
    
    def load_calculator_data
      @calculator_data ||= YAML.load(File.open("lib/data/child_maintenance_data.yml").read)
    end

  end
end
