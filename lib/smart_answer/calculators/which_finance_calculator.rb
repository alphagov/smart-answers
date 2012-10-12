require 'data/finance_weighting'

module SmartAnswer::Calculators
  class WhichFinanceCalculator
    
    attr_reader :finance_data

    FINANCE_TYPES = [:shares, :loans, :grants, :overdrafts, :invoices, :leasing]
    FINANCE_CRITERIA = [:assets, :property, :shares, :revenue, :funding_min, :funding_max, :employees]

    def initialize()
      load_finance_data
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

    def load_finance_data
      @finance_data ||= YAML.load(File.open("lib/data/which_finance_data.yml").read)
    end
  end
end
