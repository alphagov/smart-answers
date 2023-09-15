require_relative "../../test_helper"

module SmartAnswer::Calculators
  class ConsulateDataQueryTest < ActiveSupport::TestCase
    context ConsulateDataQuery do
      setup do
        @described_class = ConsulateDataQuery
        @query = @described_class.new
      end

      context "has_consulate?" do
        should "be true for countries with a consulate" do
          assert @query.has_consulate?("russia")
          assert_not @query.has_consulate?("uganda")
        end
      end

      context "has_consulate_general?" do
        should "be true for countries with a consulate general" do
          assert @query.has_consulate_general?("brazil")
          assert_not @query.has_consulate_general?("uganda")
        end
      end
    end
  end
end
