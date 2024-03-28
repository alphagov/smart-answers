module SmartAnswer::Calculators
  class RatesQuery
    def self.from_file(rates_filename, load_path: "config/smart_answers/rates")
      rates_data_path = Rails.root.join(load_path, "#{rates_filename}.yml")
      rates_yaml = YAML.load_file(rates_data_path, permitted_classes: [Date, Symbol])
      rates_data = rates_yaml.map(&:with_indifferent_access)
      new(rates_data)
    end

    attr_reader :data

    def initialize(rates_data)
      @data = rates_data
    end

    def previous_period
      previous_period = nil
      data.each do |rates_hash|
        previous_period = rates_hash if !previous_period || rates_hash[:start_date] <= previous_period[:start_date]
      end
      previous_period
    end

    def current_period
      current_period = nil
      data.each do |rates_hash|
        current_period = rates_hash if !current_period || rates_hash[:start_date] > current_period[:start_date]
      end
      current_period
    end

    def rates(date = nil)
      date ||= SmartAnswer::DateHelper.current_day
      relevant_rates = data.find do |rates_hash|
        rates_hash[:start_date] <= date && rates_hash[:end_date] >= date
      end
      relevant_rates ||= data.last

      OpenStruct.new(relevant_rates)
    end
  end
end
