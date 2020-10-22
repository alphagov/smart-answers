module SmartAnswer::Calculators
  class BenefitCapCalculatorConfiguration
    def self.weekly_benefit_caps(region = :national)
      data.fetch(:weekly_benefit_caps)[region].with_indifferent_access
    end

    def self.weekly_benefit_cap_descriptions(region = :national)
      weekly_benefit_caps(region).each_with_object(HashWithIndifferentAccess.new) do |(key, value), weekly_benefit_cap_description|
        weekly_benefit_cap_description[key] = value.fetch(:description)
      end
    end

    def self.weekly_benefit_cap_amount(family_type, region = :national)
      weekly_benefit_caps(region).fetch(family_type)[:amount]
    end

    def self.benefits
      data.fetch(:benefits).with_indifferent_access
    end

    def self.exempt_benefits
      data.fetch(:exempt_benefits)
    end

    def self.exempted_benefits?(exempted_benefits)
      ListValidator.new(exempt_benefits.keys).all_valid?(exempted_benefits)
    end

    def self.questions
      benefits.each_with_object(HashWithIndifferentAccess.new) do |(key, value), benefits_and_questions|
        benefits_and_questions[key] = value.fetch(:question)
      end
    end

    def self.descriptions
      benefits.each_with_object(HashWithIndifferentAccess.new) do |(key, value), benefits_and_descriptions|
        benefits_and_descriptions[key] = value.fetch(:description)
      end
    end

    def self.region(postcode)
      london?(postcode) ? :london : :national
    end

    def self.london?(postcode)
      area(postcode).any? do |result|
        result["type"] == "EUR" && result["name"] == "London"
      end
    end

    def self.area(postcode)
      response = GdsApi.imminence.areas_for_postcode(postcode)&.to_hash
      OpenStruct.new(response).results || []
    end

    def self.data
      @data ||= YAML.load_file(Rails.root.join("config/smart_answers/benefit_cap_data.yml")).with_indifferent_access
    end
  end
end
