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

      context '#alternate_embassy_location' do
        setup do
          @calculator = OverseasPassportsCalculator.new
        end

        should 'return a location if current_location is in PassportAndEmbassyDataQuery::ALT_EMBASSIES' do
          PassportAndEmbassyDataQuery::ALT_EMBASSIES.each do |current_location, alternate_location|
            @calculator.current_location = current_location
            assert_equal @calculator.alternate_embassy_location, alternate_location
          end
        end

        should 'return nil if current_location is not in PassportAndEmbassyDataQuery::ALT_EMBASSIES' do
          @calculator.current_location = 'antarctica'
          assert_nil @calculator.alternate_embassy_location
        end
      end

      context '#world_location' do
        setup do
          @calculator = OverseasPassportsCalculator.new
          @calculator.current_location = 'some location'
        end

        context 'given alternate_embassy_location is nil' do
          setup do
            @calculator.stubs(:alternate_embassy_location).returns(nil)
          end

          should 'return the world location for current_location' do
            WorldLocation.stubs(:find).with(@calculator.current_location).returns('world_location')

            assert_equal 'world_location', @calculator.world_location
          end

          should 'return nil if a world location cannot be found for the current_location' do
            WorldLocation.stubs(:find).with(@calculator.current_location).returns(nil)

            assert_nil @calculator.world_location
          end
        end

        context 'given alternate_embassy_location is not nil' do
          setup do
            @calculator.stubs(:alternate_embassy_location).returns('another location')
          end

          should 'return the world location for alternate_embassy_location' do
            WorldLocation.stubs(:find).with(@calculator.alternate_embassy_location).returns('world_location')

            assert_equal 'world_location', @calculator.world_location
          end

          should 'return nil if a world location cannot be found for the alternate_embassy_location' do
            WorldLocation.stubs(:find).with(@calculator.alternate_embassy_location).returns(nil)

            assert_nil @calculator.world_location
          end
        end

        context '#world_location_name' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'return the name of the world location associated with the current_location' do
            @calculator.stubs(:world_location).returns(OpenStruct.new(name: 'world_location_name'))

            assert_equal 'world_location_name', @calculator.world_location_name
          end
        end

        context '#fco_organisation' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'return the fco organisation for the world location with the current location' do
            @calculator.stubs(:world_location).returns(OpenStruct.new(fco_organisation: 'fco_organisation'))

            assert_equal 'fco_organisation', @calculator.fco_organisation
          end

          should "return nil if the world location doesn't have an fco organisation" do
            @calculator.stubs(:world_location).returns(OpenStruct.new(fco_organisation: nil))

            assert_nil @calculator.fco_organisation
          end
        end

        context '#cash_only_country?' do
          should 'delegate to the data_query' do
            data_query = PassportAndEmbassyDataQuery.new
            data_query.stubs(:cash_only_countries?).with('antarctica').returns(true)

            @calculator = OverseasPassportsCalculator.new(data_query: data_query)
            @calculator.current_location = 'antarctica'

            assert @calculator.cash_only_country?
          end
        end

        context '#renewing_country?' do
          should 'delegate to the data query' do
            data_query = PassportAndEmbassyDataQuery.new
            data_query.stubs(:renewing_countries?).with('antarctica').returns(true)

            @calculator = OverseasPassportsCalculator.new(data_query: data_query)
            @calculator.current_location = 'antarctica'

            assert @calculator.renewing_country?
          end
        end

        context '#renewing_new?' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'be true when renewing a new passport' do
            @calculator.application_action = 'renewing_new'
            assert @calculator.renewing_new?
          end

          should 'be false when not renewing a new passport' do
            @calculator.application_action = nil
            refute @calculator.renewing_new?
          end
        end

        context '#renewing_old?' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'be true when renewing an old passport' do
            @calculator.application_action = 'renewing_old'
            assert @calculator.renewing_old?
          end

          should 'be false when not renewing an old passport' do
            @calculator.application_action = nil
            refute @calculator.renewing_old?
          end
        end

        context '#applying?' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'be true when applying for a new passport' do
            @calculator.application_action = 'applying'
            assert @calculator.applying?
          end

          should 'be false when not applying for a new passport' do
            @calculator.application_action = nil
            refute @calculator.applying?
          end
        end

        context '#replacing?' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'be true when replacing a passport' do
            @calculator.application_action = 'replacing'
            assert @calculator.replacing?
          end

          should 'be false when not replacing a new passport' do
            @calculator.application_action = nil
            refute @calculator.replacing?
          end
        end
      end
    end
  end
end
