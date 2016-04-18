require_relative "../../test_helper"

module SmartAnswer::Calculators
  class WorkplacePensionCalculatorTest < ActiveSupport::TestCase
    context "enrollment data test" do
      should "(low) return 1 October 2015" do
        assert_equal "1 October 2015", WorkplacePensionCalculator.enrollment_date(38)
      end
      should "(high) return 1 January 2013" do
        assert_equal "1 January 2013", WorkplacePensionCalculator.enrollment_date(33033)
      end
      should "(edge highest) return 1 October 2012" do
        assert_equal "1 October 2012", WorkplacePensionCalculator.enrollment_date(125000)
      end
      should "(edge 61) return 1 August 2014" do
        assert_equal "1 August 2014", WorkplacePensionCalculator.enrollment_date(61)
      end
      should "(edge 58) return 1 January 2015" do
        assert_equal "1 January 2015", WorkplacePensionCalculator.enrollment_date(58)
      end
      should "(edge 57) return 1 March 2015" do
        assert_equal "1 March 2015", WorkplacePensionCalculator.enrollment_date(57)
      end
    end

    context "lower earnings limit annual rate" do
      should "return the lel rate based on the date" do
        Timecop.travel(Date.parse("2013-04-07")) do
          assert_equal 5564, WorkplacePensionCalculator.new.lel_annual_rate
        end
      end
    end
    context "lower earnings limit annual rate" do
      should "return the lel rate based on the date" do
        Timecop.travel(Date.parse("2013-04-08")) do
          assert_equal 5668, WorkplacePensionCalculator.new.lel_annual_rate
        end
      end
    end
    context "threshold limit annual rate" do
      should "return the threshold rate based on the date" do
        Timecop.travel(Date.parse("2013-04-07")) do
          assert_equal 8105, WorkplacePensionCalculator.new.threshold_annual_rate
        end
      end
    end
    context "threshold limit annual rate" do
      should "return the lel rate based on the date" do
        Timecop.travel(Date.parse("2013-04-08")) do
          assert_equal 9440, WorkplacePensionCalculator.new.threshold_annual_rate
        end
      end
    end
  end
end
