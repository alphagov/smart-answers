module SmartAnswer::Calculators
  class RegisterABirthCalculator
    include ActiveModel::Model

    attr_accessor :country_of_birth

    def initialize
      @reg_data_query = RegistrationsDataQuery.new
    end

    def registration_country
      @reg_data_query.registration_country_slug(country_of_birth)
    end
  end
end
