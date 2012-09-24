module SmartAnswer::Calculators
  class ChildMaintenanceCalculator
    
    attr_reader :calculation_scheme
    attr_accessor :net_income, :number_of_other_children, :number_of_shared_care_nights
    
    OLD_SCHEME_BASE_AMOUNT = 5
    NEW_SCHEME_BASE_AMOUNT = 7
    REDUCED_RATE_THRESHOLD = 100
    BASIC_PLUS_RATE_THRESHOLD = 800
    
    def initialize(number_of_children)
      @number_of_children = number_of_children.to_i
      # Arbitrary scheme threshold determined by number of children
      @calculation_scheme = @number_of_children > 3 ? :new : :old
      load_calculator_data
    end
    
    def rate_type
      @calculator_data[:rates][@calculation_scheme].find { |r| @net_income <= r[:max] }[:rate]
    end
    
    def calculate_maintenance_payment
      send("calculate_#{rate_type}_rate_payment")
    end
    
    def calculate_reduced_rate_payment
      reduced_rate = ((@net_income - REDUCED_RATE_THRESHOLD) * reduced_rate_mulitplier) + base_amount
      (reduced_rate - (reduced_rate * shared_care_multiplier)).round(2)
    end
    
    def calculate_basic_rate_payment
      basic_rate = @net_income - (@net_income * relevant_other_child_multiplier)
      basic_rate = (basic_rate * basic_rate_multiplier)
      (basic_rate - (basic_rate * shared_care_multiplier)).round(2)
    end
    
    def calculate_basic_plus_rate_payment
      basic_plus_rate = @net_income - (@net_income * relevant_other_child_multiplier)
      basic_qualifying_child_amount = (BASIC_PLUS_RATE_THRESHOLD * basic_rate_multiplier)
      additional_qualifying_child_amount = ((basic_plus_rate - BASIC_PLUS_RATE_THRESHOLD) * basic_plus_rate_multiplier)
      child_amounts_total = basic_qualifying_child_amount + additional_qualifying_child_amount
      (child_amounts_total - (child_amounts_total * shared_care_multiplier)).round(2)
    end
    
    def reduced_rate_mulitplier
      matrix = @calculator_data[scheme_sym(:reduced_rate_mulitpliers)]
      matrix[number_of_other_children_index][number_of_qualifying_children_index]
    end
    
    def basic_rate_multiplier
      matrix = @calculator_data[scheme_sym(:basic_rate_multipliers)]
      matrix[number_of_other_children_index][number_of_qualifying_children_index]
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
