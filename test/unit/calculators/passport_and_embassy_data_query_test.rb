require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PassportAndEmbassyDataQueryTest < ActiveSupport::TestCase
    context PassportAndEmbassyDataQuery do
      setup do
        @query = PassportAndEmbassyDataQuery.new
      end

      context "find_passport_data" do
        should "find passport data by country slug" do
          assert_equal 'ips_application_3', @query.find_passport_data('algeria')['type']
          assert_equal 'ips_documents_group_3', @query.find_passport_data('algeria')['group']
          assert_equal 'hmpo_1_application_form', @query.find_passport_data('algeria')['app_form']
          assert_equal '6 weeks', @query.find_passport_data('afghanistan')['renewing_new']
          assert_equal '6 months', @query.find_passport_data('afghanistan')['renewing_old']
          assert_equal '6 months', @query.find_passport_data('afghanistan')['applying']
          assert_equal '14 weeks', @query.find_passport_data('afghanistan')['replacing']
        end
      end

      context '#find_passport_fee' do
        setup do
          @fees = YAML.load_file(Rails.root.join('test', 'fixtures', 'fees', 'passport_fees.yml'))
          @query = PassportAndEmbassyDataQuery.new(passport_fees: @fees)
        end

        should 'return the default fees for an adult navigating through the YML file' do
          assert_equal 2, @query.find_passport_fee('adult', 'standard', 'total')
        end

        should 'raise an exception if the fee is not found' do
          assert_raise(KeyError) { @query.find_passport_fee('adult', 'i_dont_exist') }
        end
      end
    end
  end
end
