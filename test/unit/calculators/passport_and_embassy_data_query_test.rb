require_relative "../../test_helper"

module SmartAnswer::Calculators
  class PassportAndEmbassyDataQueryTest < ActiveSupport::TestCase

  	context PassportAndEmbassyDataQuery do

      setup do
        @query = PassportAndEmbassyDataQuery.new
      end

      context "find_passport_data" do
        should "find passport data by country slug" do
          assert_equal 'afghanistan', @query.find_passport_data('afghanistan')['type']
          assert_equal 'ips_documents_group_3', @query.find_passport_data('afghanistan')['group']
          assert_equal 'afghanistan', @query.find_passport_data('afghanistan')['helpline']
        end
      end

      context "retain_passport?" do
        should "indicate whether to retain your passport when applying from the given country" do
          assert @query.retain_passport?('angola')
          refute @query.retain_passport?('france')
        end
      end

      context "passport_costs" do
        should "format passport costs" do
          %w(south_african_rand_adult_32 south_african_rand_adult_48 south_african_rand_child
            euros_adult_32 euros_adult_48 euros_child).each do |k|
            assert @query.passport_costs.has_key?(k), "passport_costs should have key #{k}"
          end
          assert_match /^\d,\d\d\d South African Rand/, @query.passport_costs["south_african_rand_adult_48"]
        end
      end

    end
  end
end
