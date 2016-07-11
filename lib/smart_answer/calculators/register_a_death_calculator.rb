module SmartAnswer::Calculators
  class RegisterADeathCalculator
    include ActiveModel::Model

    attr_accessor :location_of_death
    attr_accessor :death_location_type
    attr_accessor :death_expected
    attr_accessor :country_of_death

    def initialize(attributes = {})
      super
      @reg_data_query = RegistrationsDataQuery.new
    end

    def died_in_uk?
      %w(england_wales scotland northern_ireland).include?(location_of_death)
    end

    def died_at_home_or_in_hospital?
      death_location_type == 'at_home_hospital'
    end

    def death_expected?
      death_expected == 'yes'
    end

    def registration_country
      @reg_data_query.registration_country_slug(country_of_death)
    end

    def country_has_no_embassy?
      %w(iran libya syria yemen).include?(country_of_death)
    end

    def responded_with_commonwealth_country?
      RegistrationsDataQuery::COMMONWEALTH_COUNTRIES.include?(country_of_death)
    end
  end
end
