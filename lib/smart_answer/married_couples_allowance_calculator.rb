module SmartAnswer
  class MarriedCouplesAllowanceCalculator
    def calculate_allowance(income)
     validate income

      @maximum_mca = 7705
      @minimum_mca = 2960
      @income_limit = 25400
      
      @age_related_allowance = 10660
      @personal_allowance = 8105

      mca_entitlement = @maximum_mca
       
      if income > @income_limit
        calculated_reduction = (income - @income_limit) / 2
        maximum_reduction_of_age_related_allowance = @age_related_allowance - @personal_allowance
        calculated_adjustment = calculated_reduction - maximum_reduction_of_age_related_allowance

        if calculated_adjustment > 0 
          uncapped_entitlement = @maximum_mca - calculated_adjustment
          if uncapped_entitlement > @minimum_mca
            mca_entitlement = uncapped_entitlement
          else
            mca_entitlement = @minimum_mca
          end
        else
          mca_entitlement = @maximum_mca
        end
      end

      mca = mca_entitlement * 0.1
      Money.new(mca)
    end

    def validate(income)
      raise SmartAnswer::InvalidResponse if income < 1
    end
  end
end