module SmartAnswer::Calculators
  class TranslatorLinks
    attr_reader :links, :alternate_links

    def initialize
      @links = self.class.translator_links
      @alternate_links = self.class.alternate_links
    end

    def self.translator_links
      YAML.load_file(Rails.root.join("lib", "data", "translators.yml"))
    end

    def self.alternate_links
      YAML.load_file(Rails.root.join("lib", "data", "alternative_translators_links.yml"))
    end

    def alternate_link?(country)
      @alternate_links.has_key?(country)
    end
  end
end
