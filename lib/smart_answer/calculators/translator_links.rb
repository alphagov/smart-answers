module SmartAnswer::Calculators
  class TranslatorLinks
    attr_reader :links
    
    def initialize 
      @links = self.class.translator_links
    end
    
    def translator_link(country_slug)
      links['translator_links'][country_slug]
    end
    
    def self.translator_links
      @translators ||= YAML.load_file(Rails.root.join("lib","data","translators.yml"))
    end
  end
end