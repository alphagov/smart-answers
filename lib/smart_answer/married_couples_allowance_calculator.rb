module SmartAnswer

  class MarriedCouplesAllowanceCalculator

    def calculate_allowance(income)
     validate income

      @maximum_mca = 7295
      @minimum_mca = 2800
      @income_limit = 24000
      @age_related_allowance = 12615
      @personal_allowance = 10000

      if income > @income_limit
        puts "income  #{income} and income limit:  #{@income_limit}"

        income_limit_difference = income - @income_limit/2
        puts "income limit difference: #{income_limit_difference}"

        personal_allowance_difference = @age_related_allowance - @personal_allowance
        puts "personal allowance difference: #{personal_allowance_difference}"

        mca_entitlement_difference = income_limit_difference - personal_allowance_difference
        puts "mca entitlement difference: #{mca_entitlement_difference}"

        personal_mca_entitlement = @maximum_mca - mca_entitlement_difference
        puts "personal mca entitlement: #{personal_mca_entitlement}"

        mca = personal_mca_entitlement * 0.1
        puts mca

        if mca < @minimum_mca
          Money.new((@minimum_mca * 0.1))
        elsif (mca > @maximum_mca)
          Money.new((@maximum_mca * 0.1))
        else
          Money.new(mca)
        end

      else
        Money.new((@maximum_mca * 0.1))
      end
    end

    def validate(income)
      raise SmartAnswer::InvalidResponse if income < 1
    end
  end
end