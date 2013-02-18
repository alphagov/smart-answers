require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RegistrationsDataQueryTest < ActiveSupport::TestCase
    
    context RegistrationsDataQuery do
      setup do
        @query = SmartAnswer::Calculators::RegistrationsDataQuery.new
      end
      context "registration_data method" do
        should "read registrations data" do
          assert_equal Hash, @query.data.class
          assert_equal Array, @query.data['commonwealth_countries'].class
        end
      end
      context "commonwealth_country? method" do
        should "indicate whether a country slug refers to a commonwealth country" do
          assert @query.commonwealth_country?('australia')
          refute @query.commonwealth_country?('spain')         
        end
      end
      context "clickbook method" do
        should "return the url for a country with a single clickbook url" do
          assert_equal "http://www.britishembassyinbsas.clickbook.net/", @query.clickbook('argentina')
        end
        should "return a hash of urls keyed by city for countries with multiple clickbooks" do
          clickbook = @query.clickbook('china')
          assert_equal Hash, clickbook.class
          assert_equal "Beijing", clickbook.keys.first
          assert_equal "https://www.clickbook.net/dev/bc.nsf/sub/BritConChongqing", clickbook["Chongqing"]
        end
      end
    end
  end
end
