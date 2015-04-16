module SmartAnswer::Calculators
  class RatesQuery
    def initialize(rates_filename, relevant_date: nil)
      @rates_filename = rates_filename
      @relevant_date = relevant_date
    end

    def relevant_fiscal_year
      @relevant_fiscal_year ||= begin
        year = relevant_date.year
        threshold = "#{year}-04-05".to_date
        if relevant_date <= threshold
          year - 1
        else
          year
        end
      end
    end

    def rates
      return @rates if @rates
      if data[:type] == "exact_dates"
        exact_date_rates
      else
        standard_date_rates
      end
    end

  private

    def load_path
      @load_path ||= File.join("lib", "data", "rates")
    end

    def data
      @data ||= YAML.load_file(Rails.root.join(load_path, "#{@rates_filename}.yml")).with_indifferent_access
    end

    def relevant_date
      @relevant_date ||= Date.today
    end

    def exact_date_rates
      rates = data[:rates].find do |rates_hash|
        rates_hash[:start_date] <= relevant_date && rates_hash[:end_date] >= relevant_date
      end
      rates ||= data[:rates].last

      @rates = OpenStruct.new(rates)
    end

    def standard_date_rates
      rates = {}
      data.keys.each do |rate_name|
        rates[rate_name] = data[rate_name][relevant_fiscal_year] || data[rate_name].values.last
      end
      @rates = OpenStruct.new(rates)
    end
  end
end
