module SmartAnswer::Calculators
  class PropertyFireSafetyPaymentCalculator
    attr_accessor :year_of_purchase

    FIRST_VALID_YEAR = 1945
    LAST_VALID_YEAR = 2022

    def valid_year_of_purchase?
      @year_of_purchase.between?(FIRST_VALID_YEAR, LAST_VALID_YEAR)
    end
  end
end
