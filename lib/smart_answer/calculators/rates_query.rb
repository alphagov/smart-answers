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
      rates = {}
      data.keys.each do |rate_name|
        rates[rate_name] = data[rate_name][relevant_fiscal_year] || data[rate_name].values.last
      end
      @rates = OpenStruct.new(rates)
    end
  private

    def data
      @data ||= YAML.load_file(Rails.root.join("lib", "data", "rates", "#{@rates_filename}.yml"))
    end

    def relevant_date
      @relevant_date ||= Date.today
    end
  end
end
