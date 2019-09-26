module SmartAnswer::Calculators
  class RegisterADeathCalculator
    include ActiveModel::Model

    EXCLUDE_COUNTRIES = %w(holy-see british-antarctic-territory).freeze

    attr_accessor :location_of_death
    attr_accessor :death_location_type
    attr_accessor :death_expected
    attr_accessor :country_of_death
    attr_accessor :current_location
    attr_accessor :current_country

    def initialize(attributes = {})
      super
      @reg_data_query = RegistrationsDataQuery.new
      @country_name_query = CountryNameFormatter.new
      @translator_query = TranslatorLinks.new
    end

    def died_in_uk?
      %w(england_wales scotland northern_ireland).include?(location_of_death)
    end

    def died_at_home_or_in_hospital?
      death_location_type == "at_home_hospital"
    end

    def death_expected?
      death_expected == "yes"
    end

    def registration_country
      @reg_data_query.registration_country_slug(current_country || country_of_death)
    end

    def registration_country_name_lowercase_prefix
      @country_name_query.definitive_article(registration_country)
    end

    def death_country_name_lowercase_prefix
      @country_name_query.definitive_article(country_of_death)
    end

    def country_has_no_embassy?
      %w(libya syria yemen somalia).include?(country_of_death)
    end

    def responded_with_commonwealth_country?
      RegistrationsDataQuery::COMMONWEALTH_COUNTRIES.include?(country_of_death)
    end

    def in_the_uk?
      current_location == "in_the_uk"
    end

    def same_country?
      current_location == "same_country"
    end

    def another_country?
      current_location == "another_country"
    end

    def died_in_north_korea?
      country_of_death == "north-korea"
    end

    def currently_in_north_korea?
      current_country == "north-korea"
    end

    def translator_link_url
      @translator_query.links[country_of_death]
    end

    def overseas_passports_embassies
      location = WorldLocation.find(registration_country)
      organisation = location.fco_organisation

      if organisation
        organisation.offices_with_service "Births and Deaths registration service"
      else
        []
      end
    end

    def document_return_fees
      @reg_data_query.document_return_fees
    end

    def fee_for_registering_a_death
      @reg_data_query.register_a_death_fees.register_a_death
    end

    def fee_for_copy_of_death_registration_certificate
      @reg_data_query.register_a_death_fees.copy_of_death_registration_certificate
    end

    def oru_documents_variant_for_death?
      @reg_data_query.oru_documents_variant_for_death?(country_of_death)
    end

    def oru_courier_variant?
      @reg_data_query.oru_courier_variant?(registration_country)
    end

    def oru_courier_by_high_commission?
      @reg_data_query.oru_courier_by_high_commission?(registration_country)
    end
  end
end
