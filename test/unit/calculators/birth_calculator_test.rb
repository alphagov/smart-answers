require_relative "../../test_helper"

module SmartAnswer::Calculators
  class BirthCalculatorTest < ActiveSupport::TestCase
    context BirthCalculator do
      context "basic tests" do
 # Birth 22/12/12
 # QW 02/09/12 - 08/09/12
 # Employ start 17/03/12
        context "birth 2012 Dec 22" do
          setup do
            @due_date = Date.parse("2012 Dec 22")
            @calculator = BirthCalculator.new(@due_date)
          end
          should "return basic calcs" do
            assert_equal @due_date, @calculator.due_date
            assert_equal Date.parse("16 Dec 2012")..Date.parse("22 Dec 2012"), @calculator.expected_week
          end
          should "qualifying week" do
            assert_equal Date.parse("02 Sep 2012")..Date.parse("08 Sep 2012"), @calculator.qualifying_week
          end
          should "employment start" do
            assert_equal Date.parse("17 Mar 2012"), @calculator.employment_start
          end
        end
      end
    end
  end
end
