module SmartAnswer::Calculators
  class MarriageAbroadCalculator
    attr_accessor :ceremony_country
    attr_writer :resident_of
    attr_writer :partner_nationality
    attr_writer :sex_of_your_partner
    attr_accessor :marriage_or_pacs

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
      marriage_or_pacs == 'marriage'
    end
  end
end
