module SmartAnswer::Calculators
  class RatesQuery
    def self.from_file(rates_filename, load_path: nil)
      new(rates_filename, load_path: load_path)
    end

    attr_reader :load_path

    def initialize(rates_filename, load_path: nil)
      @load_path = load_path || File.join("lib", "data", "rates")
      @rates_filename = rates_filename
    end

    def rates(relevant_date = Date.today)
      relevant_rates = data.find do |rates_hash|
        rates_hash[:start_date] <= relevant_date && rates_hash[:end_date] >= relevant_date
      end
      relevant_rates ||= data.last

      OpenStruct.new(relevant_rates)
    end

  private

    def data
      @data ||= YAML.load_file(Rails.root.join(load_path, "#{@rates_filename}.yml")).map(&:with_indifferent_access)
    end
  end
end
