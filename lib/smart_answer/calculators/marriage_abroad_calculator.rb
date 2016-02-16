module SmartAnswer::Calculators
  class MarriageAbroadCalculator
    attr_accessor :ceremony_country
    attr_writer :resident_of
    attr_writer :partner_nationality
    attr_writer :sex_of_your_partner
    attr_writer :marriage_or_pacs

    def initialize(data_query: nil)
      @data_query = data_query || MarriageAbroadDataQuery.new
    end

    def partner_british?
      @partner_nationality == 'partner_british'
    end

    def partner_not_british?
      !partner_british?
    end

    def partner_is_national_of_ceremony_country?
      @partner_nationality == 'partner_local'
    end

    def partner_is_not_national_of_ceremony_country?
      !partner_is_national_of_ceremony_country?
    end

    def partner_is_neither_british_nor_a_national_of_ceremony_country?
      @partner_nationality == 'partner_other'
    end

    def resident_of_uk?
      @resident_of == 'uk'
    end

    def resident_outside_of_uk?
      !resident_of_uk?
    end

    def resident_of_ceremony_country?
      @resident_of == 'ceremony_country'
    end

    def resident_outside_of_ceremony_country?
      !resident_of_ceremony_country?
    end

    def resident_of_third_country?
      @resident_of == 'third_country'
    end

    def resident_outside_of_third_country?
      !resident_of_third_country?
    end

    def partner_is_opposite_sex?
      @sex_of_your_partner == 'opposite_sex'
    end

    def partner_is_same_sex?
      @sex_of_your_partner == 'same_sex'
    end

    def want_to_get_married?
      @marriage_or_pacs == 'marriage'
    end

    def world_location
      WorldLocation.find(ceremony_country) || raise(SmartAnswer::InvalidResponse)
    end

    def ceremony_country_name
      world_location.name
    end

    def fco_organisation
      world_location.fco_organisation
    end

    def overseas_passports_embassies
      if fco_organisation
        fco_organisation.offices_with_service 'Registrations of Marriage and Civil Partnerships'
      else
        []
      end
    end

    def marriage_and_partnership_phrases
      if @data_query.ss_marriage_countries?(ceremony_country) || @data_query.ss_marriage_countries_when_couple_british?(ceremony_country)
        'ss_marriage'
      elsif @data_query.ss_marriage_and_partnership?(ceremony_country)
        'ss_marriage_and_partnership'
      end
    end
  end
end
