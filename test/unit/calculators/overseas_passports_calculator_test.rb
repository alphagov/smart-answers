require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class OverseasPassportsCalculatorTest < ActiveSupport::TestCase
      context '#current_location' do
        setup do
          @calculator = OverseasPassportsCalculator.new
        end

        should 'allow current_location to be written and read' do
          @calculator.current_location = 'springfield'
          assert_equal @calculator.current_location, 'springfield'
        end
      end

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


      context '#uk_visa_application_with_colour_pictures?' do
        setup do
          @calculator = OverseasPassportsCalculator.new
        end

        should 'be true if current_location is in UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES' do
          OverseasPassportsCalculator::UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES.each do |country|
            @calculator.current_location = country
            assert @calculator.uk_visa_application_with_colour_pictures?
          end
        end

        should 'be false if current_location is not in UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES' do
          @calculator.current_location = 'antarctica'
          refute @calculator.uk_visa_application_with_colour_pictures?
        end
      end


      context '#non_uk_visa_application_with_colour_pictures?' do
        setup do
          @calculator = OverseasPassportsCalculator.new
        end

        should 'be true if current_location is in NON_UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES' do
          OverseasPassportsCalculator::NON_UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES.each do |country|
            @calculator.current_location = country
            assert @calculator.non_uk_visa_application_with_colour_pictures?
          end
        end

        should 'be false if current_location is not in NON_UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES' do
          @calculator.current_location = 'antarctica'
          refute @calculator.non_uk_visa_application_with_colour_pictures?
        end
      end

      context '#ineligible_country?' do
        setup do
          @calculator = OverseasPassportsCalculator.new
        end

        should 'be true if current_location is in INELIGIBLE_COUNTRIES' do
          OverseasPassportsCalculator::INELIGIBLE_COUNTRIES.each do |country|
            @calculator.current_location = country
            assert @calculator.ineligible_country?
          end
        end

        should 'be false if current_location is not in INELIGIBLE_COUNTRIES' do
          @calculator.current_location = 'antarctica'
          refute @calculator.ineligible_country?
        end
      end

      context '#apply_in_neighbouring_countries?' do
        setup do
          @calculator = OverseasPassportsCalculator.new
        end

        should 'be true if current_location is in APPLY_IN_NEIGHBOURING_COUNTRIES' do
          OverseasPassportsCalculator::APPLY_IN_NEIGHBOURING_COUNTRIES.each do |country|
            @calculator.current_location = country
            assert @calculator.apply_in_neighbouring_countries?
          end
        end

        should 'be false if current_location is not in APPLY_IN_NEIGHBOURING_COUNTRIES' do
          @calculator.current_location = 'antarctica'
          refute @calculator.apply_in_neighbouring_countries?
        end
      end
    end
  end
end
