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

      context "find_embassy_data" do
        should "find embassy data by country slug" do
          assert_equal 'Baghdad.consularenquiries@fco.gov.uk', @query.find_embassy_data('iraq', false).first['email']
        end
        should "find alternative embassy data by slug" do
          assert_equal 'Amman.enquiries@fco.gov.uk', @query.find_embassy_data('iraq').first['email']
        end
      end

      context "retain_passport?" do
        should "indicate whether to retain your passport when applying from the given country" do
          assert @query.retain_passport?('afghanistan')
          refute @query.retain_passport?('france')
        end
      end
      
    end
  end
end
