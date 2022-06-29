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
        if @shared_ownership == "yes"
          @percentage_owned * TEN_THOUSAND
        else
          TEN_THOUSAND
        end
      elsif uprated_value_of_property.between?(INSIDE_LONDON_VALUATION_LIMIT, ONE_MILLION) && live_in_london == "yes"
        if @shared_ownership == "yes"
          @percentage_owned * FIFTEEN_THOUSAND
        else
          FIFTEEN_THOUSAND
        end
      elsif uprated_value_of_property >= TWO_MILLION
        if @shared_ownership == "yes"
          @percentage_owned * ONE_HUNDRED_THOUSAND
        else
          ONE_HUNDRED_THOUSAND
        end
      else
        uprated_value_of_property >= ONE_MILLION
        if @shared_ownership == "yes"
          @percentage_owned * FIFTY_THOUSAND
        else
          FIFTY_THOUSAND
        end
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
  end
end
