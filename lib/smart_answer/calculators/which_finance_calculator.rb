require 'data/finance_weighting'

module SmartAnswer::Calculators
  class WhichFinanceCalculator
    
    attr_reader :finance_data

    FINANCE_TYPES = [:shares, :loans, :grants, :overdrafts, :invoices, :leasing]
    FINANCE_CRITERIA = [:assets, :property, :shares, :revenue, :funding_min, :funding_max, :employees]

    def initialize()
      @finance_data = self.class.which_finance_data
    end

    def calculate_inclusions(answers)
      inclusions = {}
      calculate_weighted_scores(answers).each do |k,v|
        inclusions[k] = inclusion_sym(v) 
      end
      inclusions
    end

    def inclusion_sym(val)
      return :yes   if val >= 90
      return :maybe if val >= 55
      :no
    end

    def calculate_weighted_scores(answers)
      weighted_scores = {}
      FINANCE_TYPES.each do |ft|
        weighted_scores[ft] = 0
        finance_weighting = finance_data.find { |d| d.finance_type == ft }
        FINANCE_CRITERIA.each do |criterion|
          if answers.has_key?(criterion) and finance_weighting.respond_to?(criterion)
            weighted_scores[ft] += finance_weighting.score(answers[criterion], criterion) 
          end
        end
      end
      weighted_scores
    end

    def self.which_finance_data
      @which_finance_data ||= YAML.load_file(Rails.root.join("lib/data/which_finance_data.yml"))
    end
  end
end
