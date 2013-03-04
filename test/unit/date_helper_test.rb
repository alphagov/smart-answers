require_relative "../test_helper"

module SmartAnswer
  class DateHelperTest < ActiveSupport::TestCase
    include DateHelper

    context "next_saturday" do
      should "return the following saturday for a provided date" do
        assert_equal Date.parse("2012 Mar 03"), next_saturday(Date.parse("2012 March 01"))
      end
    end
  end
end
