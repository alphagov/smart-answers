module SmartAnswer::Calculators
  class StaticDataQuery
    cattr_reader :datas
    attr_reader :data

    def initialize(data_name)
      @data = self.class.load_data(data_name)
    end

    def self.load_data(data_name)
      @datas ||= {}
      @datas[data_name] ||= YAML.load_file(Rails.root.join("lib", "data", data_name + ".yml"))
    end
  end
end
