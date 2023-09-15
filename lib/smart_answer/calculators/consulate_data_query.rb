module SmartAnswer::Calculators
  class ConsulateDataQuery
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

    def has_consulate?(country_slug)
      COUNTRIES_WITH_CONSULATES.include?(country_slug)
    end

    def has_consulate_general?(country_slug)
      COUNTRIES_WITH_CONSULATE_GENERALS.include?(country_slug)
    end
  end
end
