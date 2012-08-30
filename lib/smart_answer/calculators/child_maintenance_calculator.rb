module SmartAnswer::Calculators
  class ChildMaintenanceCalculator
    
    # TODO: to yml
    RATES = {
      :new => [
        {:max => 7, :rate => :nil}, 
        {:max => 100, :rate => :flat}, 
        {:max => 200, :rate => :reduced}, 
        {:max => 800, :rate => :basic}, 
        {:max => 3000, :rate => :basic_plus}
      ],
      :old => [
        {:max => 5, :rate => :nil},
        {:max => 100, :rate => :flat},
        {:max => 200, :rate => :reduced},
        {:max => 800, :rate => :basic},
        {:max => 3000, :rate => :basic_plus}
      ]
    }
    
    REDUCED_RATE_MULTIPLIERS = [
      [0.25,  0.35,  0.45],
      [0.205, 0.29,  0.37],
      [0.19,  0.27,  0.375],
      [0.175, 0.25,  0.325]
    ]
    BASIC_RATE_MULTIPLIERS = [
      [0.12,  0.16,  0.19],
      [0.12,  0.16,  0.19],
      [0.131, 0.198, 0.249],
      [0.124, 0.189, 0.237]
    ]
    
    SHARED_CARE_REDUCTIONS = [0, 0.14, 0.28, 0.42, 0.5]
    RELEVANT_OTHER_CHILD_REDUCTIONS = [0, 0.12, 0.16, 0.19]
    
    attr_reader :calculation_scheme
    attr_accessor :net_income, :number_of_other_children, :number_of_shared_care_nights
    
    def initialize(number_of_children)
      @number_of_children = number_of_children.to_i
      @calculation_scheme = @number_of_children > 3 ? :new : :old
    end
    
    def rate_type
      RATES[@calculation_scheme].find { |r| @net_income <= r[:max] }[:rate]
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
    
    def reduced_rate_mulitplier
      REDUCED_RATE_MULTIPLIERS[number_of_other_children_index][number_of_qualifying_children_index]
    end
    
    def basic_rate_multiplier
      BASIC_RATE_MULTIPLIERS[number_of_other_children_index][number_of_qualifying_children_index]
    end
    
    def shared_care_multiplier
      SHARED_CARE_REDUCTIONS[@number_of_shared_care_nights]
    end
    
    def relevant_other_child_multiplier
      RELEVANT_OTHER_CHILD_REDUCTIONS[number_of_other_children_index]
    end

    def number_of_other_children_index
      @number_of_other_children > 3 ? 3 : @number_of_other_children
    end
    
    def number_of_qualifying_children_index
      (@number_of_children > 3 ? 3 : @number_of_children) - 1
    end

  end
end
