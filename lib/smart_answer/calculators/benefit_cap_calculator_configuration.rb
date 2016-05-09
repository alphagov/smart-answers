module SmartAnswer::Calculators
  class BenefitCapCalculatorConfiguration
    def weekly_benefit_caps(version, region = :national)
      data(version).fetch(:weekly_benefit_caps)[region].with_indifferent_access
    end

    def weekly_benefit_cap_descriptions(version, region = :national)
      weekly_benefit_caps(version, region).inject(HashWithIndifferentAccess.new) do |weekly_benefit_cap_description, (key, value)|
        weekly_benefit_cap_description[key] = value.fetch(:description)
        weekly_benefit_cap_description
      end
    end

    def weekly_benefit_cap_amount(version, family_type, region = :national)
      weekly_benefit_caps(version, region).fetch(family_type)[:amount]
    end

    def benefits(version)
      data(version).fetch(:benefits).with_indifferent_access
    end

    def exempt_benefits(version)
      data(version).fetch(:exempt_benefits)
    end

    def questions(version)
      benefits(version).inject(HashWithIndifferentAccess.new) do |benefits_and_questions, (key, value)|
        benefits_and_questions[key] = value.fetch(:question)
        benefits_and_questions
      end
    end

    def descriptions(version)
      benefits(version).inject(HashWithIndifferentAccess.new) do |benefits_and_descriptions, (key, value)|
        benefits_and_descriptions[key] = value.fetch(:description)
        benefits_and_descriptions
      end
    end

    def all_questions
      dataset.keys.inject({}) { |versions, version| versions.merge(questions(version)) }
    end

    def region(postcode)
      is_london?(postcode) ? :london : :national
    end

    def is_london?(postcode)
      area(postcode).any? { |result| result[:slug] == "london" }
    end

    def area(postcode)
      response = Services.imminence_api.areas_for_postcode(postcode)
      (response&.results || {})
    end


  private

    def dataset
      @dataset ||= YAML.load_file(Rails.root.join('lib', 'data', 'benefit_cap_data.yml')).with_indifferent_access
    end

    def data(version)
      dataset.fetch(version)
    end
  end
end
