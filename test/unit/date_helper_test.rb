require_relative "../test_helper"
require_relative "../../lib/smart_answer/date_helper"

module SmartAnswer
  class DateHelperTest < ActiveSupport::TestCase
    include DateHelper

    context "next_saturday" do
      should "return the following saturday for a provided date" do
        assert_equal Date.parse("2012 Mar 03"), next_saturday(Date.parse("2012 March 01"))
      end
    end

    context "current day" do
      should "return today, if rates query date is not set" do
        Timecop.freeze("2016-09-27") do
          assert_equal Date.parse("2016-09-27"), SmartAnswer::DateHelper.current_day
        end
      end

      context "rates query date is set" do
        should "return the rates query date" do
          ENV["RATES_QUERY_DATE"] = "2016-12-31"
          assert_equal Date.parse("2016-12-31"), SmartAnswer::DateHelper.current_day
        end

        teardown do
          ENV.delete "RATES_QUERY_DATE"
        end
      end
    end
  end
end
