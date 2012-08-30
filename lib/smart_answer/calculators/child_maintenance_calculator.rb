module SmartAnswer::Calculators
  class ChildMaintenanceCalculator
    
    attr_reader :calculation_scheme
    attr_accessor :net_income, :number_of_other_children, :number_of_shared_care_nights
    
    def initialize(number_of_children)
      @number_of_children = number_of_children.to_i
      @calculation_scheme = @number_of_children > 3 ? :new : :old
      load_calculator_data
    end
    
    def rate_type
      @calculator_data[:rates][@calculation_scheme].find { |r| @net_income <= r[:max] }[:rate]
      # RATES[@calculation_scheme].find { |r| @net_income <= r[:max] }[:rate]
    end
    
    def calculate_reduced_rate_payment
      reduced_rate = ((@net_income - 100) * reduced_rate_mulitplier) + 7
      (reduced_rate - (reduced_rate * shared_care_multiplier)).round(2)
    end
    
    def calculate_basic_rate_payment
      basic_rate = @net_income - (@net_income * relevant_other_child_multiplier)
      basic_rate = (basic_rate * basic_rate_multiplier)
      (basic_rate - (basic_rate * shared_care_multiplier)).round(2)
    end
    
    def calculate_basic_plus_rate_payment
      basic_plus_rate = @net_income - (@net_income * relevant_other_child_multiplier)
    end
    
    def reduced_rate_mulitplier
      @calculator_data[:reduced_rate_mulitpliers][number_of_other_children_index][number_of_qualifying_children_index]
    end
    
    def basic_rate_multiplier
      @calculator_data[:basic_rate_multipliers][number_of_other_children_index][number_of_qualifying_children_index]
    end
    
    def shared_care_multiplier
      @calculator_data[:shared_care_reductions][@number_of_shared_care_nights]
    end
    
    def relevant_other_child_multiplier
      @calculator_data[:relevant_other_child_reductions][number_of_other_children_index]
    end

    def number_of_other_children_index
      @number_of_other_children > 3 ? 3 : @number_of_other_children
    end
    
    def number_of_qualifying_children_index
      (@number_of_children > 3 ? 3 : @number_of_children) - 1
    end
    
    def load_calculator_data
      @calculator_data ||= YAML.load(File.open("lib/data/child_maintenance_data.yml").read)
    end

  end
end
