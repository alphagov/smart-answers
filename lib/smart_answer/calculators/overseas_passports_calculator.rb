module SmartAnswer::Calculators
  class OverseasPassportsCalculator
    BOOK_APPOINTMENT_ONLINE_COUNTRIES = %w(
      kyrgyzstan tajikistan turkmenistan uzbekistan
    )

    attr_accessor :current_location

    def book_appointment_online?
      BOOK_APPOINTMENT_ONLINE_COUNTRIES.include?(current_location)
    end
  end
end
