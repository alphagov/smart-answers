module SmartdownPlugins
  module RegisterABirthTransition
    extend DataPartial

    @country_name_query = ::SmartAnswer::Calculators::CountryNameFormatter.new

    @reg_data_query = ::SmartAnswer::Calculators::RegistrationsDataQuery.new
    @translator_query = ::SmartAnswer::Calculators::TranslatorLinks.new

    COUNTRIES_WITHOUT_EMBASSY = %w(iran syria yemen)
    CHECKLIST_COUNTRIES = %w(bangladesh kuwait libya north-korea pakistan philippines turkey)

    def self.pay_button
      locals = {button_data: {text: "Pay now", url: "https://pay-register-birth-abroad.service.gov.uk/start"}}
      render 'button', locals: locals
    end

    def self.embassies(country)
      location = WorldLocation.find(slug(country))
      #or import invalidresponse from smart answers?
      raise Exception("InvalidResponse") unless location
      organisations = [location.fco_organisation]

      if organisations and organisations.any?
        service_title = 'Births and Deaths registration service'
        embassies = organisations.first.offices_with_service(service_title)
      else
        embassies = []
      end
      embassies
    end

    def self.embassy_data(country)
      locals = {overseas_passports_embassies: embassies(country)}
      render 'overseas_passports_embassies', locals: locals
    end

    def self.country_has_no_embassy(country)
      COUNTRIES_WITHOUT_EMBASSY.include?(country.value)
    end

    def self.commonwealth_country(country)
      @reg_data_query.class::COMMONWEALTH_COUNTRIES.include?(country.value)
    end

    def self.oru_exception(country)
      @reg_data_query.class::ORU_TRANSITION_EXCEPTIONS.include?(country.value)
    end

    def self.oru_country(country)
      @reg_data_query.class::ORU_TRANSITIONED_COUNTRIES.include?(country.value)
    end

    def self.post_only(country)
      @reg_data_query.post_only_countries?(slug(country))
    end

    def self.postal_return_form(country)
      @reg_data_query.postal_return_form(slug(country))
    end

    def self.postal_form_url(country)
      @reg_data_query.postal_form(slug(country))
    end

    def self.no_postal_countries(country)
      @reg_data_query.class::NO_POSTAL_COUNTRIES.include?(slug(country))
    end

    def self.slug(country)
      @reg_data_query.registration_country_slug(country.value)
    end

    def self.slug_with_lower_case_prefix(country)
      @country_name_query.definitive_article(slug(country))
    end

    def self.country_with_high_commission(country)
      @reg_data_query.class::COUNTRIES_WITH_HIGH_COMMISSIONS.include?(country.value)
    end

    def self.country_with_consulate(country)
      @reg_data_query.class::COUNTRIES_WITH_CONSULATES.include?(country.value)
    end

    def self.country_with_trade_cultural_offices(country)
      @reg_data_query.class::COUNTRIES_WITH_TRADE_CULTURAL_OFFICES.include?(country.value)
    end

    def self.country_with_consulate_general(country)
      @reg_data_query.class::COUNTRIES_WITH_CONSULATE_GENERALS.include?(country.value)
    end

    def self.checklist_countries(country)
      CHECKLIST_COUNTRIES.include?(slug(country))
    end

    def self.footnote_exclusions(country)
      @reg_data_query.class::FOOTNOTE_EXCLUSIONS.include?(slug(country))
    end

    def self.oru_courier_variants(country)
      @reg_data_query.class::ORU_COURIER_VARIANTS.include?(slug(country))
    end

    def self.not_oru_courier_variants(country)
      ! @reg_data_query.class::ORU_COURIER_VARIANTS.include?(slug(country))
    end

    def self.oru_document_variants(country)
      @reg_data_query.class::ORU_DOCUMENTS_VARIANT_COUNTRIES.include?(slug(country))
    end

    def self.embassy_high_commission_or_consulate(country)
      if @reg_data_query.class::COUNTRIES_WITH_HIGH_COMMISSIONS.include?(slug(country))
        "British high commission"
      elsif @reg_data_query.class::COUNTRIES_WITH_CONSULATES.include?(slug(country))
        "British consulate"
      elsif @reg_data_query.class::COUNTRIES_WITH_TRADE_CULTURAL_OFFICES.include?(slug(country))
        "British Trade & Cultural Office"
      elsif @reg_data_query.class::COUNTRIES_WITH_CONSULATE_GENERALS.include?(slug(country))
        "British consulate general"
      else
        "British embassy"
      end
    end

    def self.pay_by_bank_draft(country)
      @reg_data_query.pay_by_bank_draft?(slug(country))
    end

    def self.cash_only(country)
      @reg_data_query.cash_only?(slug(country))
    end

    def self.cash_and_card_only(country)
      @reg_data_query.cash_and_card_only?(slug(country))
    end

    def self.modified_card_only_country(country)
      @reg_data_query.modified_card_only_countries?(slug(country))
    end

    def self.country_has_translator_link(country)
      @translator_query.links[country.value]
    end

    def self.eastern_caribbean_country(country)
      @reg_data_query.eastern_caribbean_countries?(country)
    end

    #TODO: we should be able to do this without using a plugin
    def self.not_same_country(country1, country2)
      true if country1.value != country2.value
    end

  end
end
