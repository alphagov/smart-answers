module SmartAnswer::Calculators
  class PropertyFireSafetyPaymentCalculator
    attr_accessor :year_of_purchase,
                  :value_of_property,
                  :live_in_london,
                  :shared_ownership,
                  :percentage_owned

    FIRST_VALID_YEAR = 1945
    LAST_VALID_YEAR = 2022
    OUTSIDE_LONDON_VALUATION_LIMIT = 175_000
    INSIDE_LONDON_VALUATION_LIMIT = 325_000
    ONE_MILLION = 1_000_000
    TWO_MILLION = 2_000_000
    TEN_THOUSAND = 10_000
    FIFTEEN_THOUSAND = 15_000
    FIFTY_THOUSAND = 50_000
    ONE_HUNDRED_THOUSAND = 100_000

    def valid_year_of_purchase?
      @year_of_purchase.between?(FIRST_VALID_YEAR, LAST_VALID_YEAR)
    end

    def property_uprating_values
      @property_uprating_values ||= YAML.load_file(Rails.root.join("config/smart_answers/property_fire_safety_payment_data.yml")).freeze
    end

    def uprated_value_of_property
      (property_uprating_values.fetch(@year_of_purchase, default_uprating_value) * @value_of_property.to_f).ceil
    end

    def fully_protected_from_costs?
      under_valuation_limit_living_inside_london || under_valuation_limit_living_outside_london
    end

    def leaseholder_costs
      if uprated_value_of_property.between?(OUTSIDE_LONDON_VALUATION_LIMIT, ONE_MILLION) && live_in_london == "no"
        shared_ownership_costs(TEN_THOUSAND)
      elsif uprated_value_of_property.between?(INSIDE_LONDON_VALUATION_LIMIT, ONE_MILLION) && live_in_london == "yes"
        shared_ownership_costs(FIFTEEN_THOUSAND)
      elsif uprated_value_of_property >= TWO_MILLION
        shared_ownership_costs(ONE_HUNDRED_THOUSAND)
      elsif uprated_value_of_property >= ONE_MILLION
        shared_ownership_costs(FIFTY_THOUSAND)
      end
    end

  private

    def default_uprating_value
      property_uprating_values["default"]
    end

    def under_valuation_limit_living_inside_london
      uprated_value_of_property <= OUTSIDE_LONDON_VALUATION_LIMIT && live_in_london == "no"
    end

    def under_valuation_limit_living_outside_london
      uprated_value_of_property <= INSIDE_LONDON_VALUATION_LIMIT && live_in_london == "yes"
    end

    def shared_ownership_costs(basic_cost)
      @shared_ownership == "yes" ? @percentage_owned * basic_cost : basic_cost
    end
  end
end
