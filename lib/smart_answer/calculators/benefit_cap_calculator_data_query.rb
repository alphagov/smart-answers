module SmartAnswer::Calculators
  class BenefitCapCalculatorDataQuery
    attr_reader :data, :benefits, :questions
    def data
      @data ||= YAML.load_file(Rails.root.join('lib', 'data', 'benefit_cap_data.yml'))
    end

    def benefits
      @benefits ||=  @data.fetch("benefits").with_indifferent_access
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
  end
end
