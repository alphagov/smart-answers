module SmartAnswer::Calculators
  class WorkplacePensionCalculator
    attr_reader :data

    def threshold_annual_rate
      if Date.today < Date.civil(2013, 4, 8)
        8105.0
      elsif Date.today >= Date.civil(2013, 4, 8)
        9440.0
      end
    end

    def threshold_monthly_rate
      (threshold_annual_rate / 12).ceil
    end

    def threshold_weekly_rate
      (threshold_annual_rate / 52).ceil
    end

    def lel_annual_rate
      if Date.today < Date.civil(2013, 4, 8)
        5564.0
      elsif Date.today >= Date.civil(2013, 4, 8)
        5668.0
      end
    end

    def lel_monthly_rate
      (lel_annual_rate / 12).ceil
    end

    def lel_weekly_rate
      (lel_annual_rate / 52).ceil
    end

    def self.enrollment_date(num)
      enrollment_data(num)[:start_date]
    end

    def self.enrollment_data(num)
      load_calculator_data.find do |d|
        num >= d[:min_employees] and num <= d[:max_employees]
      end
    end

    def self.load_calculator_data
      @load_calculator_data ||= YAML.load(File.open("lib/data/workplace_pension_data.yml").read)[:enrollment_data]
    end
  end
end
