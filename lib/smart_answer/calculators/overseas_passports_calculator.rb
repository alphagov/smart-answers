module SmartAnswer::Calculators
  class OverseasPassportsCalculator
    BOOK_APPOINTMENT_ONLINE_COUNTRIES = %w(
      kyrgyzstan tajikistan turkmenistan uzbekistan
    )

    UK_VISA_APPLICATION_CENTRE_COUNTRIES = %w(afghanistan algeria azerbaijan bangladesh belarus burundi burma cambodia china gaza georgia india indonesia kazakhstan kyrgyzstan laos lebanon mauritania morocco nepal pakistan russia tajikistan thailand turkmenistan ukraine uzbekistan western-sahara vietnam venezuela)

    attr_accessor :current_location

    def book_appointment_online?
      BOOK_APPOINTMENT_ONLINE_COUNTRIES.include?(current_location)
    end

    def uk_visa_application_centre?
      UK_VISA_APPLICATION_CENTRE_COUNTRIES.include?(current_location)
    end
  end
end
