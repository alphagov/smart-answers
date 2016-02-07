module SmartAnswer::Calculators
  class MarriageAbroadCalculator
    attr_accessor :partner_nationality

    def partner_british?
      partner_nationality == 'partner_british'
    end
  end
end
