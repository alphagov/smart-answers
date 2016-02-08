module SmartAnswer::Calculators
  class MarriageAbroadCalculator
    attr_accessor :partner_nationality

    def partner_british?
      partner_nationality == 'partner_british'
    end

    def partner_not_british?
      !partner_british?
    end

    def partner_is_national_of_ceremony_country?
      partner_nationality == 'partner_local'
    end
  end
end
