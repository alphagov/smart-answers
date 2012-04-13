module SmartAnswer

  class MarriedCouplesAllowanceCalculator

    def calculate_allowance(amount)
     validate amount

      @maximum = 729.50
      @minimum = 280

      if amount > 24000
        income = (amount - 24000)/2 - 2615
        income = (7295-income) * 0.1

        if income < @minimum
          Money.new(@minimum)
        elsif (income > @maximum)
          Money.new(@maximum)
        else
          Money.new(income)
        end

      else
        Money.new(@maximum)
      end
    end

    def validate(amount)
      raise SmartAnswer::InvalidResponse if amount < 1
    end
  end
end