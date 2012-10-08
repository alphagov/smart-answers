module SmartAnswer::Calculators
  class WorkplacePensionCalculator
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