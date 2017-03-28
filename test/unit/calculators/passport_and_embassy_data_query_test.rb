require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PassportAndEmbassyDataQueryTest < ActiveSupport::TestCase
    context PassportAndEmbassyDataQuery do
      setup do
        @query = PassportAndEmbassyDataQuery.new
      end

      context "find_passport_data" do
        should "find passport data by country slug" do
          assert_equal 'ips_application_2', @query.find_passport_data('algeria')['type']
          assert_equal 'ips_documents_group_3', @query.find_passport_data('algeria')['group']
          assert_equal 'hmpo_1_application_form', @query.find_passport_data('algeria')['app_form']
          assert_equal '6 weeks', @query.find_passport_data('afghanistan')['renewing_new']
          assert_equal '6 months', @query.find_passport_data('afghanistan')['renewing_old']
          assert_equal '6 months', @query.find_passport_data('afghanistan')['applying']
          assert_equal '14 weeks', @query.find_passport_data('afghanistan')['replacing']
        end
      end

      context '#find_passport_fee' do
        should 'return the passport fee for an adult standard passport type' do
          assert_equal 83.00, @query.find_passport_fee('adult_standard')
        end
        should 'return the passport fee for an adult jumbo passport type' do
          assert_equal 91.00, @query.find_passport_fee('adult_jumbo')
        end
        should 'return the passport fee for a child passport type' do
          assert_equal 53.00, @query.find_passport_fee('child')
        end
      end
    end
  end
end
