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
    
    SHARED_CARE_REDUCTIONS = [0, 0.14, 0.28, 0.42, 0.5]
    
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
      reduced_rate = ((@net_income_of_payee - 100) * reduced_rate_mulitplier) + 7
      (reduced_rate - (reduced_rate * shared_care_multiplier)).round(2)
    end
    
    def reduced_rate_mulitplier
      number_of_qualifying_children = @number_of_children > 3 ? 3 : @number_of_children
      number_of_other_children = @number_of_other_children > 3 ? 3 : @number_of_other_children
      REDUCED_RATE_MULTIPLIERS[number_of_other_children][number_of_qualifying_children - 1]
    end
    
    def shared_care_multiplier
      SHARED_CARE_REDUCTIONS[@number_of_shared_care_nights]
    end
  end
end
