module SmartAnswer::Calculators
  class CommodityCodeCalculator
    
    attr_reader :matrix_data, :commodity_code_matrix
    
    def initialize(weights)
      load_maxtrix_data
      populate_commodity_code_matrix
      
      puts commodity_code_matrix.first
#      ["starch_glucose_weight", "sucrose_weight", "milk_fat_weight", "milk_protein_weight"].each do |n|
#        send("@#{n}=", weights[n.to_sym].to_i)
#      end
      @starch_glucose_weight = weights[:starch_glucose_weight].to_i
      @sucrose_weight = weights[:sucrose_weight].to_i
      @milk_fat_weight = weights[:milk_fat_weight].to_i
      @milk_protein_weight = weights[:milk_protein_weight].to_i
    end
    
    def commodity_code
      glucose_sucrose_index = starch_glucose_to_sucrose[@starch_glucose_weight][@sucrose_weight]
      milk_fat_milk_protein_index = milk_fat_to_milk_protein[@milk_fat_weight][@milk_protein_weight]
      @commodity_code_matrix[glucose_sucrose_index][milk_fat_milk_protein_index].to_s     
    end
    
    def populate_commodity_code_matrix
      @commodity_code_matrix = @matrix_data[:commodity_code_matrix].lines.map { |l| l.split }
    end
    
    def starch_glucose_to_sucrose
      @matrix_data[:starch_glucose_to_sucrose]
    end
    
    def milk_fat_to_milk_protein
      @matrix_data[:milk_fat_to_milk_protein]
    end
    
    def load_maxtrix_data
      @matrix_data ||= YAML.load(File.open("lib/data/commodity_codes_data.yml").read)  
    end    
  end
end
