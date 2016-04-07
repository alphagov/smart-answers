module SmartAnswer::Calculators
  class BenefitCapCalculatorDataQuery
    attr_reader :data
    def data
      @data ||= YAML.load_file(Rails.root.join('lib', 'data', 'benefit_cap_data.yml'))
    end
  end
end
