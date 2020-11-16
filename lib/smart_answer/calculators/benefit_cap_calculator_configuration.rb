module SmartAnswer::Calculators
  module BenefitCapCalculatorConfiguration
    def self.data
      @data ||= begin
        filepath = Rails.root.join("config/smart_answers/benefit_cap_data.yml")
        YAML.load_file(filepath).with_indifferent_access
      end
    end

  module_function

    def benefits
      data.fetch(:benefits).with_indifferent_access
    end

    def exempt_benefits
      data.fetch(:exempt_benefits)
    end

    def weekly_benefit_caps(region = :national)
      data.fetch(:weekly_benefit_caps)[region].with_indifferent_access
    end

    def new_housing_benefit_amount(housing_benefit_amount, total_over_cap)
      housing_benefit_amount.to_f - total_over_cap.to_f
    end

    def new_housing_benefit(amount)
      amount = sprintf("%.2f", amount)
      if amount < "0.5"
        amount = sprintf("%.2f", 0.5)
      end
      amount
    end

    def weekly_benefit_cap_descriptions(region = :national)
      weekly_benefit_caps(region).each_with_object(HashWithIndifferentAccess.new) do |(key, value), weekly_benefit_cap_description|
        weekly_benefit_cap_description[key] = value.fetch(:description)
      end
    end

    def weekly_benefit_cap_amount(family_type, region = :national)
      weekly_benefit_caps(region).fetch(family_type)[:amount]
    end

    def exempted_benefits?(exempted_benefits)
      ListValidator.new(exempt_benefits.keys).all_valid?(exempted_benefits)
    end

    def questions
      benefits.each_with_object(HashWithIndifferentAccess.new) do |(key, value), benefits_and_questions|
        benefits_and_questions[key] = value.fetch(:question)
      end
    end

    def descriptions
      benefits.each_with_object(HashWithIndifferentAccess.new) do |(key, value), benefits_and_descriptions|
        benefits_and_descriptions[key] = value.fetch(:description)
      end
    end

    def region(postcode)
      london?(postcode) ? :london : :national
    end

    def london?(postcode)
      area(postcode).any? do |result|
        result["type"] == "EUR" && result["name"] == "London"
      end
    end

    def area(postcode)
      response = GdsApi.imminence.areas_for_postcode(postcode)&.to_hash
      OpenStruct.new(response).results || []
    end
  end
end
