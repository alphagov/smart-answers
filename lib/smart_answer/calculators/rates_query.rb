module SmartAnswer::Calculators
  class RatesQuery
    def self.from_file(rates_filename, load_path: nil)
      load_path ||= File.join("lib", "data", "rates")
      rates_data_path = Rails.root.join(load_path, "#{rates_filename}.yml")
      rates_data = YAML.load_file(rates_data_path).map(&:with_indifferent_access)
      new(rates_data)
    end

    attr_reader :data

    def initialize(rates_data)
      @data = rates_data
    end

    def rates(date = nil)
      date = date || SmartAnswer::DateHelper.current_day
      relevant_rates = data.find do |rates_hash|
        rates_hash[:start_date] <= date && rates_hash[:end_date] >= date
      end
      relevant_rates ||= data.last

      OpenStruct.new(relevant_rates)
    end
  end
end
