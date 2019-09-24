module SmartAnswer::Calculators
  class CountryNameFormatter
    COUNTRIES_WITH_DEFINITIVE_ARTICLES = %w(bahamas british-virgin-islands cayman-islands czech-republic democratic-republic-of-the-congo dominican-republic falkland-islands maldives marshall-islands netherlands philippines seychelles solomon-islands south-georgia-and-the-south-sandwich-islands turks-and-caicos-islands united-arab-emirates).freeze

    FRIENDLY_COUNTRY_NAME = {
      "cote-d-ivoire" => "Cote d'Ivoire",
      "pitcairn" => "Pitcairn Island",
      "south-korea" => "South Korea",
      "st-helena-ascension-and-tristan-da-cunha" => "St Helena, Ascension and Tristan da Cunha",
      "usa" => "the USA",
    }.freeze

    def definitive_article(country, capitalized = false)
      result = country_name(country)
      if requires_definite_article?(country)
        result = capitalized ? "The #{result}" : "the #{result}"
      end
      result
    end

    def requires_definite_article?(country)
      COUNTRIES_WITH_DEFINITIVE_ARTICLES.include?(country)
    end

    def has_friendly_name?(country)
      FRIENDLY_COUNTRY_NAME.has_key?(country)
    end

    def friendly_name(country)
      FRIENDLY_COUNTRY_NAME[country]
    end

  private

    def country_name(country)
      WorldLocation.find(country).name
    end
  end
end
