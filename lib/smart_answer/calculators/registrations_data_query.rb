module SmartAnswer::Calculators
  class RegistrationsDataQuery
    COUNTRIES_WITH_CONSULATES = %w[
      china
      colombia
      israel
      russia
      turkey
    ].freeze

    COUNTRIES_WITH_CONSULATE_GENERALS = %w[
      brazil
      hong-kong
      turkey
    ].freeze

    attr_reader :data

    def initialize
      @data = self.class.registration_data
    end

    def has_consulate?(country_slug)
      COUNTRIES_WITH_CONSULATES.include?(country_slug)
    end

    def has_consulate_general?(country_slug)
      COUNTRIES_WITH_CONSULATE_GENERALS.include?(country_slug)
    end

    def self.registration_data
      @registration_data ||= YAML.load_file(Rails.root.join("config/smart_answers/registrations.yml"))
    end
  end
end
