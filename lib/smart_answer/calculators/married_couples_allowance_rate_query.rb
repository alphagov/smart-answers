module SmartAnswer::Calculators
  class MarriedCouplesAllowanceRateQuery
    def self.data
      @data ||= YAML.load_file(Rails.root.join("lib", "data", "married_couples_allowance_rates.yml"))
    end

    data.keys.each do |rate_name|
      define_method rate_name do
        data[rate_name][current_fiscal_year] || data[rate_name].values.last
      end
    end

    def current_fiscal_year
      @current_fiscal_year ||= begin
        today = Date.today
        current_year = today.year
        threshold = "#{current_year}-04-05".to_date
        if today <= threshold
          current_year - 1
        else
          current_year
        end
      end
    end

    def data
      self.class.data
    end
  end
end
