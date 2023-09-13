module SmartAnswer::Calculators
  class RegisterADeathCalculator
    include ActiveModel::Model

    EXCLUDE_COUNTRIES = %w[holy-see british-antarctic-territory].freeze

    attr_accessor :location_of_death,
                  :death_location_type,
                  :death_expected,
                  :country_of_death,
                  :current_location,
                  :current_country

    def initialize(attributes = {})
      super
      @reg_data_query = RegistrationsDataQuery.new
      @country_name_query = CountryNameFormatter.new
      @translator_query = TranslatorLinks.new
    end

    def died_in_uk?
      %w[england_wales scotland northern_ireland].include?(location_of_death)
    end

    def died_at_home_or_in_hospital?
      death_location_type == "at_home_hospital"
    end

    def death_expected?
      death_expected == "yes"
    end

    def fee_for_registering_a_death
      @reg_data_query.register_a_death_fees.register_a_death
    end

    def fee_for_copy_of_death_registration_certificate
      @reg_data_query.register_a_death_fees.copy_of_death_registration_certificate
    end
  end
end
