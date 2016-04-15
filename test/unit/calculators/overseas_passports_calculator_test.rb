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

        should 'return a alt location if the location is in PassportAndEmbassyDataQuery::ALT_EMBASSIES' do
          PassportAndEmbassyDataQuery::ALT_EMBASSIES.each do |location, alternate_location|
            assert_equal @calculator.alternate_embassy_location(location), alternate_location
          end
        end

        should 'return nil if the location is not in PassportAndEmbassyDataQuery::ALT_EMBASSIES' do
          assert_nil @calculator.alternate_embassy_location('antarctica')
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

          should 'return the world location for the location' do
            WorldLocation.stubs(:find).with('location').returns('world_location')

            assert_equal 'world_location', @calculator.world_location('location')
          end

          should 'return nil if a world location cannot be found for the location' do
            WorldLocation.stubs(:find).with('location').returns(nil)

            assert_nil @calculator.world_location('location')
          end
        end

        context 'given alternate_embassy_location is present' do
          setup do
            @calculator.stubs(:alternate_embassy_location).returns('another location')
          end

          should 'return the world location for alternate_embassy_location' do
            WorldLocation.stubs(:find).with(@calculator.alternate_embassy_location).returns('world_location')

            assert_equal 'world_location', @calculator.world_location('another location')
          end

          should 'return nil if a world location cannot be found for the alternate_embassy_location' do
            WorldLocation.stubs(:find).with(@calculator.alternate_embassy_location).returns(nil)

            assert_nil @calculator.world_location('another location')
          end
        end

        context '#world_location_name' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'return the name of the world location associated with the location' do
            @calculator.stubs(:world_location).with('location').returns(stub(name: 'world-location-name'))

            assert_equal 'world-location-name', @calculator.world_location_name('location')
          end
        end

        context '#fco_organisation' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'return the fco organisation for the world location with the location' do
            @calculator.stubs(:world_location).with('location').returns(stub(fco_organisation: 'fco-organisation'))

            assert_equal 'fco-organisation', @calculator.fco_organisation('location')
          end

          should "return nil if the world location doesn't have an fco organisation" do
            @calculator.stubs(:world_location).with('location').returns(stub(fco_organisation: nil))

            assert_nil @calculator.fco_organisation('location')
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
            @calculator.application_action = 'renewing_old'
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
            @calculator.application_action = 'renewing_new'
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
            @calculator.application_action = 'replacing'
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
            @calculator.application_action = 'applying'
            refute @calculator.replacing?
          end
        end

        context '#overseas_passports_embassies' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'return the offices that offer an overseas passport service' do
            world_office = stub('World Office')
            organisation = stub.quacks_like(WorldwideOrganisation.new({}))
            organisation.stubs(:offices_with_service).with('Overseas Passports Service').returns([world_office])
            @calculator.stubs(:fco_organisation).with('location').returns(organisation)

            assert_equal [world_office], @calculator.overseas_passports_embassies('location')
          end

          should 'return an empty array when there is no FCO organisation' do
            @calculator.stubs(:fco_organisation).with('location').returns(nil)

            assert_equal [], @calculator.overseas_passports_embassies('location')
          end
        end

        context '#general_action' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          context 'given application action is renewing_new' do
            should 'equal renewing' do
              @calculator.application_action = 'renewing_new'
              assert_equal @calculator.general_action, 'renewing'
            end
          end

          context 'given application action is renewing_old' do
            should 'equal renewing' do
              @calculator.application_action = 'renewing_old'
              assert_equal @calculator.general_action, 'renewing'
            end
          end

          context 'given application action is replacing' do
            should 'equal replacing' do
              @calculator.application_action = 'replacing'
              assert_equal @calculator.general_action, 'replacing'
            end
          end

          context 'given application action is applying' do
            should 'equal applying' do
              @calculator.application_action = 'applying'
              assert_equal @calculator.general_action, 'applying'
            end
          end
        end

        context '#passport_data' do
          should 'delegate to the data_query' do
            data_query = PassportAndEmbassyDataQuery.new
            data_query.stubs(:find_passport_data).with('antarctica').returns('passport-data')

            @calculator = OverseasPassportsCalculator.new(data_query: data_query)
            @calculator.current_location = 'antarctica'

            assert_equal 'passport-data', @calculator.passport_data
          end

          context 'when receiving an argument value' do
            should 'delegate to the data_query with the argument value' do
              data_query = PassportAndEmbassyDataQuery.new
              data_query.stubs(:find_passport_data).with('arctic').returns('passport-data')

              @calculator = OverseasPassportsCalculator.new(data_query: data_query)

              assert_equal 'passport-data', @calculator.passport_data('arctic')
            end
          end
        end

        context '#application_type' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'returns type from passport_data' do
            application_type = 'application_type_x'
            @calculator.stubs(:passport_data).returns('type' => 'application_type_x')

            assert_equal application_type, @calculator.application_type
          end

          should 'return nil when passport_data is nil' do
            @calculator.stubs(:passport_data).returns(nil)

            assert_nil @calculator.application_type
          end
        end

        context '#application_form' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'returns app_form from passport_data' do
            application_form = 'application_form_1'
            @calculator.stubs(:passport_data).returns('app_form' => 'application_form_1')

            assert_equal application_form, @calculator.application_form
          end

          should 'return nil when passport_data is nil' do
            @calculator.stubs(:passport_data).returns(nil)

            assert_nil @calculator.application_form
          end
        end

        context '#application_office?' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'be true when the passport_data application_office is present' do
            @calculator.stubs(:passport_data).returns('application_office' => 'some office')

            assert @calculator.application_office?
          end

          should 'be false when the passport_data application_office is blank' do
            @calculator.stubs(:passport_data).returns('application_office' => nil)

            refute @calculator.application_office?
          end

          should 'return nil when passport data is nil' do
            @calculator.stubs(:passport_data).returns(nil)

            refute @calculator.application_office?
          end
        end

        context '#optimistic_processing_time' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'return the optimistic_processing_time? from passport_data' do
            @calculator.stubs(:passport_data).returns('optimistic_processing_time?' => 10)

            assert_equal 10, @calculator.optimistic_processing_time
          end

          should 'return nil when passport data is nil' do
            @calculator.stubs(:passport_data).returns(nil)

            assert_nil @calculator.optimistic_processing_time
          end
        end

        context '#waiting_time' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'returns the waiting time for an application action from passport_data' do
            actions = { 'renewing_new' => 1, 'renewing_old' => 2, 'applying' => 3, 'replacing' => 4 }
            @calculator.stubs(:passport_data).returns(actions)

            actions.each do |action, time|
              @calculator.application_action = action
              assert time, @calculator.waiting_time
            end
          end

          should 'return nil when passport_data is nil' do
            @calculator.stubs(:passport_data).returns(nil)

            assert_nil @calculator.waiting_time
          end
        end

        context '#application_address' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'returns address from passport_data' do
            application_address = 'application_address_1'
            @calculator.stubs(:passport_data).returns('address' => 'application_address_1')

            assert_equal application_address, @calculator.application_address
          end

          should 'return nil when passport_data is nil' do
            @calculator.stubs(:passport_data).returns(nil)

            assert_nil @calculator.application_address
          end
        end

        context '#application_group' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'returns group from passport_data for the given location' do
            application_group = 'application_group_data'
            @calculator.stubs(:passport_data).with('test-location').returns('group' => 'application_group_data')

            assert_equal application_group, @calculator.application_group('test-location')
          end

          should 'return nil when passport_data is nil' do
            @calculator.stubs(:passport_data).with('test-location').returns(nil)

            assert_nil @calculator.application_group('test-location')
          end
        end

        context '#supporting_documents' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'return application_group for the current_location when birth_location is blank' do
            @calculator.birth_location = nil
            @calculator.current_location = 'current location'
            @calculator.stubs(:application_group).with('current location').returns('supporting docs')

            assert_equal 'supporting docs', @calculator.supporting_documents
          end

          should 'return application_group for current_location when birth location is united-kingdom' do
            @calculator.birth_location = 'united kingdom'
            @calculator.current_location = 'current location'
            @calculator.stubs(:application_group).with('united kingdom').returns('supporting docs')

            assert_equal 'supporting docs', @calculator.supporting_documents
          end

          should 'return application_group for birth_location when birth_location is present and not united-kingdom' do
            @calculator.birth_location = 'birth location'
            @calculator.current_location = 'current location'
            @calculator.stubs(:application_group).with('birth location').returns('supporting docs')

            assert_equal 'supporting docs', @calculator.supporting_documents
          end
        end

        context '#ips_application?' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'be true when application_type is in IPS_APPLICATION_TYPES' do
            OverseasPassportsCalculator::IPS_APPLICATION_TYPES.each do |type|
              @calculator.stubs(:application_type).returns(type)
              assert @calculator.ips_application?
            end
          end

          should 'be false when application_type is not in IPS_APPLICATION_TYPES' do
            @calculator.stubs(:application_type).returns('application_type_x')

            refute @calculator.ips_application?
          end
        end

        context '#ips_online_application?' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'be true when passport_data online_application is present' do
            @calculator.stubs(:passport_data).returns('online_application' => 'apply online')

            assert @calculator.ips_online_application?
          end

          should 'be false when passport_data is blank' do
            @calculator.stubs(:passport_data).returns(nil)

            refute @calculator.ips_online_application?
          end

          should 'be false when passport_data online_application is blank' do
            @calculator.stubs(:passport_data).returns('online_application' => nil)

            refute @calculator.ips_online_application?
          end
        end

        context '#ips_number' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'return the IPS number when application_type is an IPS application' do
            OverseasPassportsCalculator::IPS_APPLICATION_TYPES.each do |type|
              @calculator.stubs(:application_type).returns(type)
              assert_equal type.last, @calculator.ips_number
            end
          end

          should 'return nil when application_type is not an IPS application' do
            @calculator.stubs(:application_type).returns('application_type_x')

            assert_nil @calculator.ips_number
          end
        end

        context '#ips_docs_number' do
          setup do
            @calculator = OverseasPassportsCalculator.new
          end

          should 'return the IPS docs number when application_type is an IPS application' do
            @calculator.stubs(:supporting_documents).returns("ips_documents_group_1")
            @calculator.stubs(:ips_application?).returns(true)

            assert_equal "ips_documents_group_1".last, @calculator.ips_docs_number
          end

          should 'return nil when application_type is not an IPS application' do
            @calculator.stubs(:ips_application?).returns(false)

            assert_nil @calculator.ips_docs_number
          end
        end
      end

      context '#valid_current_location?' do
        setup do
          @calculator = OverseasPassportsCalculator.new
        end

        should 'be truthy if world_location is present?' do
          @calculator.stubs(:world_location).returns(stub('world-location'))
          assert @calculator.valid_current_location?
        end

        should 'be falsey if world_location is not present?' do
          @calculator.stubs(:world_location).returns(nil)
          refute @calculator.valid_current_location?
        end
      end
    end
  end
end
