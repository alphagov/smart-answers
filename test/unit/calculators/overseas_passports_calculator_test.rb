require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class OverseasPassportsCalculatorTest < ActiveSupport::TestCase
      context '#book_appointment_online?' do
        setup do
          @calculator = OverseasPassportsCalculator.new
        end

        should 'be true if current_location is in BOOK_APPOINTMENT_ONLINE_COUNTRIES countries' do
          OverseasPassportsCalculator::BOOK_APPOINTMENT_ONLINE_COUNTRIES.each do |country|
            @calculator.current_location = country
            assert @calculator.book_appointment_online?
          end
        end

        should 'be false if current_location is not in BOOK_APPOINTMENT_ONLINE_COUNTRIES' do
          @calculator.current_location = 'antarctica'
          refute @calculator.book_appointment_online?
        end
      end

      context '#uk_visa_application_centre?' do
        setup do
          @calculator = OverseasPassportsCalculator.new
        end

        should 'be true if current_location is in UK_VISA_APPLICATION_CENTRE_COUNTRIES countries' do
          OverseasPassportsCalculator::UK_VISA_APPLICATION_CENTRE_COUNTRIES.each do |country|
            @calculator.current_location = country
            assert @calculator.uk_visa_application_centre?
          end
        end

        should 'be false if current_location is not in UK_VISA_APPLICATION_CENTRE_COUNTRIES' do
          @calculator.current_location = 'antarctica'
          refute @calculator.uk_visa_application_centre?
        end
      end
    end
  end
end
