module SmartAnswer::Calculators
  class CommodityCodeCalculator

    attr_reader :matrix_data, :commodity_code_matrix
    attr_accessor :milk_protein_weight

    def initialize(weights)
      @matrix_data = self.class.commodity_codes_data
      @commodity_code_matrix = self.class.commodity_code_matrix

      @starch_glucose_weight = weights[:starch_glucose_weight].to_i
      @sucrose_weight = weights[:sucrose_weight].to_i
      @milk_fat_weight = weights[:milk_fat_weight].to_i
      @milk_protein_weight = weights[:milk_protein_weight].to_i
    end

    def commodity_code
      @commodity_code_matrix[milk_fat_milk_protein_index][glucose_sucrose_index]
    end

    private

    def glucose_sucrose_index
      starch_glucose_to_sucrose[@starch_glucose_weight][@sucrose_weight]
    end

    def milk_fat_milk_protein_index
      milk_fat_to_milk_protein[@milk_fat_weight][@milk_protein_weight]
    end

    def starch_glucose_to_sucrose
      @matrix_data[:starch_glucose_to_sucrose]
    end

    def milk_fat_to_milk_protein
      @matrix_data[:milk_fat_to_milk_protein]
    end

    def self.commodity_code_matrix
      unless @commodity_code_matrix
        @commodity_code_matrix = []
        commodity_codes_data[:commodity_code_matrix].each_line { |l| @commodity_code_matrix << l.split }
      end
      @commodity_code_matrix
    end

    def self.commodity_codes_data
      @commodity_codes_data ||= YAML.load(File.open("lib/data/commodity_codes_data.yml").read)
    end
  end
end
