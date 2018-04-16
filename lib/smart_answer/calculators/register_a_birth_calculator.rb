module SmartAnswer::Calculators
  class RegisterABirthCalculator
    include ActiveModel::Model

    EXCLUDE_COUNTRIES = %w(holy-see british-antarctic-territory)

    attr_accessor :country_of_birth
    attr_accessor :british_national_parent
    attr_accessor :married_couple_or_civil_partnership
    attr_accessor :childs_date_of_birth
    attr_accessor :current_location
    attr_accessor :current_country

    def initialize
      @reg_data_query = RegistrationsDataQuery.new
      @country_name_query = CountryNameFormatter.new
      @translator_query = TranslatorLinks.new
    end

    def registration_country
      @reg_data_query.registration_country_slug(current_country || country_of_birth)
    end

    def registration_country_name_lowercase_prefix
      @country_name_query.definitive_article(registration_country)
    end

    def country_has_no_embassy?
      %w(libya syria yemen somalia).include?(country_of_birth)
    end

    def responded_with_commonwealth_country?
      RegistrationsDataQuery::COMMONWEALTH_COUNTRIES.include?(country_of_birth)
    end

    def paternity_declaration?
      married_couple_or_civil_partnership == 'no'
    end

    def before_july_2006?
      Date.new(2006, 07, 01) > childs_date_of_birth
    end

    def same_country?
      current_location == 'same_country'
    end

    def another_country?
      current_location == 'another_country'
    end

    def in_the_uk?
      current_location == 'in_the_uk'
    end

    def no_birth_certificate_exception?
      @reg_data_query.has_birth_registration_exception?(country_of_birth) && paternity_declaration?
    end

    def born_in_north_korea?
      country_of_birth == 'north-korea'
    end

    def currently_in_north_korea?
      current_country == 'north-korea'
    end

    def british_national_father?
      british_national_parent == 'father'
    end

    def overseas_passports_embassies
      location = WorldLocation.find(registration_country)
      organisations = [location.fco_organisation]
      if organisations && organisations.any?
        service_title = 'Births and Deaths registration service'
        organisations.first.offices_with_service(service_title)
      else
        []
      end
    end

    def fee_for_registering_a_birth
      @reg_data_query.register_a_birth_fees.register_a_birth
    end

    def fee_for_copy_of_birth_registration_certificate
      @reg_data_query.register_a_birth_fees.copy_of_birth_registration_certificate
    end

    def document_return_fees
      @reg_data_query.document_return_fees
    end

    def custom_waiting_time
      @reg_data_query.custom_registration_duration(country_of_birth)
    end

    def born_in_lower_risk_country?
      @reg_data_query.lower_risk_country?(country_of_birth)
    end

    def higher_risk_country?
      @reg_data_query.higher_risk_country?(registration_country)
    end

    def oru_documents_variant_for_birth?
      @reg_data_query.oru_documents_variant_for_birth?(country_of_birth)
    end

    def may_require_dna_tests?
      @reg_data_query.may_require_dna_tests?(country_of_birth)
    end

    def oru_courier_variant?
      @reg_data_query.oru_courier_variant?(registration_country)
    end

    def oru_courier_by_high_commission?
      @reg_data_query.oru_courier_by_high_commission?(registration_country)
    end

    def translator_link_url
      @translator_query.links[country_of_birth]
    end
  end
end
