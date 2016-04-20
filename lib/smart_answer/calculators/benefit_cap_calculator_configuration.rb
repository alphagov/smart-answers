module SmartAnswer::Calculators
  class BenefitCapCalculatorConfiguration
    def weekly_benefit_caps(version)
      data(version).fetch(:weekly_benefit_caps).with_indifferent_access
    end

    def weekly_benefit_cap_descriptions(version)
      weekly_benefit_caps(version).inject(HashWithIndifferentAccess.new) do |weekly_benefit_cap_description, (key, value)|
        weekly_benefit_cap_description[key] = value.fetch(:description)
        weekly_benefit_cap_description
      end
    end

    def weekly_benefit_cap_amount(version, family_type)
      weekly_benefit_caps(version).fetch(family_type)[:amount]
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

  private

    def dataset
      @dataset ||= YAML.load_file(Rails.root.join('lib', 'data', 'benefit_cap_data.yml')).with_indifferent_access
    end

    def data(version)
      dataset.fetch(version)
    end
  end
end
