module SmartAnswer::Calculators
  class CommodityCodeCalculator
    
    attr_reader :matrix_data
    
    def initialize(weights)
      load_maxtrix_data
#      ["starch_glucose_weight", "sucrsoe_weight", "milk_fat_weight", "milk_protein_weight"].each do |n|
#        send("@#{n}=", weights[n.to_sym].to_i)
#      end
      @starch_glucose_weight = weights[:starch_glucose_weight].to_i
      @sucrose_weight = weights[:sucrose_weight].to_i
      @milk_fat_weight = weights[:milk_fat_weight].to_i
      @milk_protein_weight = weights[:milk_protein_weight].to_i
    end
    
    def commodity_code
      
    end
    
    def starch_glucose_ranges
      @matrix_data[:starch_glucose_ranges]
    end
    
    def sucrose_ranges
      @matrix_data[:sucrose_ranges]
    end
    
    def load_maxtrix_data
      @matrix_data ||= YAML.load(File.open("lib/data/commodity_codes_data.yml").read)  
    end    
  end
end
