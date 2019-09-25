module SmartAnswer::Calculators
  class CommodityCodeCalculator
    include ActiveModel::Model

    attr_reader :matrix_data, :commodity_code_matrix

    attr_accessor :starch_glucose_weight
    attr_accessor :sucrose_weight
    attr_accessor :milk_fat_weight
    attr_accessor :milk_protein_weight

    def initialize(attributes = {})
      super
      @matrix_data = self.class.commodity_codes_data
      @commodity_code_matrix = self.class.commodity_code_matrix
      @starch_glucose_weight ||= 0
      @sucrose_weight ||= 0
      @milk_fat_weight ||= 0
      @milk_protein_weight ||= 0
    end

    def commodity_code
      @commodity_code_matrix[milk_fat_milk_protein_index][glucose_sucrose_index]
    end

    def has_commodity_code?
      commodity_code != "X"
    end

    def self.commodity_code_matrix
      unless @commodity_code_matrix
        @commodity_code_matrix = []
        commodity_codes_data[:commodity_code_matrix].each_line { |l| @commodity_code_matrix << l.split }
      end
      @commodity_code_matrix
    end

    def self.commodity_codes_data
      @commodity_codes_data ||= YAML.load(File.open("lib/data/commodity_codes_data.yml").read) # rubocop:disable Security/YAMLLoad
    end

  private

    def glucose_sucrose_index
      starch_glucose_to_sucrose[starch_glucose_weight][sucrose_weight]
    end

    def milk_fat_milk_protein_index
      milk_fat_to_milk_protein[milk_fat_weight][milk_protein_weight]
    end

    def starch_glucose_to_sucrose
      @matrix_data[:starch_glucose_to_sucrose]
    end

    def milk_fat_to_milk_protein
      @matrix_data[:milk_fat_to_milk_protein]
    end
  end
end
