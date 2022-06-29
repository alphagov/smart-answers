module SmartAnswer::Calculators
  class PropertyFireSafetyPaymentCalculator
    attr_accessor :year_of_purchase,
                  :value_of_property,
                  :live_in_london,
                  :shared_ownership,
                  :percentage_owned

    FIRST_VALID_YEAR = 1945
    LAST_VALID_YEAR = 2022

    def valid_year_of_purchase?
      @year_of_purchase.between?(FIRST_VALID_YEAR, LAST_VALID_YEAR)
    end

    def property_uprating_values
      @property_uprating_values ||= YAML.load_file(Rails.root.join("config/smart_answers/property_fire_safety_payment_data.yml")).freeze
    end

    def uprated_value_of_property
      (property_uprating_values.fetch(@year_of_purchase, default_uprating_value) * @value_of_property.to_f).ceil
    end

  private

    def default_uprating_value
      property_uprating_values["default"]
    end
  end
end
