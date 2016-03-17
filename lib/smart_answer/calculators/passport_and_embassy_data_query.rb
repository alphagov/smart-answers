module SmartAnswer::Calculators
  class PassportAndEmbassyDataQuery
    include ActionView::Helpers::NumberHelper

    ALT_EMBASSIES = {
      'benin' =>  'nigeria',
      'guinea' => 'ghana'
    }

    CASH_ONLY_COUNTRIES = %w(cuba sudan)

    RENEWING_COUNTRIES = %w(belarus burma cuba lebanon libya russia sudan tajikistan tunisia turkmenistan uzbekistan zimbabwe)

    attr_reader :passport_data

    def initialize
      @passport_data = self.class.passport_data
    end

    def find_passport_data(country_slug)
      passport_data[country_slug]
    end

    def cash_only_countries?(country_slug)
      CASH_ONLY_COUNTRIES.include?(country_slug)
    end

    def renewing_countries?(country_slug)
      RENEWING_COUNTRIES.include?(country_slug)
    end

    def self.passport_data
      @passport_data ||= YAML.load_file(Rails.root.join("lib", "data", "passport_data.yml"))
    end
  end
end
