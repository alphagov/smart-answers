module SmartAnswer::Calculators
  class TranslatorLinksV2
    attr_reader :links

    def initialize
      @links = self.class.translator_links
    end

    def self.translator_links
      @links ||= YAML.load_file(Rails.root.join("lib", "data", "translators_v2.yml"))
    end
  end
end
