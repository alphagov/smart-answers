module SmartAnswer::Calculators
  class BenefitCapCalculatorConfiguration
    def weekly_benefit_caps
      @weekly_benefit_caps ||= data.fetch("weekly_benefit_caps").with_indifferent_access
    end

    def weekly_benefit_cap_descriptions
      @weekly_benefit_cap_descriptions ||=
        weekly_benefit_caps.inject(HashWithIndifferentAccess.new) do |weekly_benefit_cap_description, (key, value)|
          weekly_benefit_cap_description[key] = value.fetch("description")
          weekly_benefit_cap_description
        end
    end

    def weekly_benefit_cap_amount(family_type)
      weekly_benefit_caps.fetch(family_type)["amount"]
    end

    def benefits
      @benefits ||= data.fetch("benefits").with_indifferent_access
    end

    def exempt_benefits
      @exempt_benefits ||= data.fetch("exempt_benefits")
    end

    def questions
      @questions ||=
        benefits.inject(HashWithIndifferentAccess.new) do |benefits_and_questions, (key, value)|
          benefits_and_questions[key] = value.fetch("question")
          benefits_and_questions
        end
    end

    def descriptions
      @descriptions ||=
        benefits.inject(HashWithIndifferentAccess.new) do |benefits_and_descriptions, (key, value)|
          benefits_and_descriptions[key] = value.fetch("description")
          benefits_and_descriptions
        end
    end

  private

    def data
      @data ||= YAML.load_file(Rails.root.join('lib', 'data', 'benefit_cap_data.yml'))
    end
  end
end
