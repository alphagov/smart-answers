module SmartAnswer
  class MarriedCouplesAllowanceCalculator

    def initialize(current_figures = {})
      @maximum_mca = current_figures[:maximum_mca]
      @minimum_mca = current_figures[:minimum_mca]
      @income_limit = current_figures[:income_limit]
      @personal_allowance = current_figures[:personal_allowance]
    end

    def calculate_allowance(age_related_allowance, income)
      validate income

      mca_entitlement = @maximum_mca

      if income > @income_limit
        attempted_reduction = (income - @income_limit) / 2

        # \/ this reduction actually applies across the board for personal allowances,
        # but extracting that was more than required for this piece of work. Please see
        # note in AgeRelatedAllowanceChooser
        maximum_reduction_of_allowances = age_related_allowance - @personal_allowance
        remaining_reduction = attempted_reduction - maximum_reduction_of_allowances

        if remaining_reduction > 0
          reduced_mca = @maximum_mca - remaining_reduction
          if reduced_mca > @minimum_mca
            mca_entitlement = reduced_mca
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