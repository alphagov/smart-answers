module SmartAnswer::Calculators
  class TranslatorLinks
    attr_reader :links

    def initialize
      @links = self.class.translator_links
    end

    def self.translator_links
      YAML.load_file(Rails.root.join("lib", "data", "translators.yml"))
    end
  end
end
