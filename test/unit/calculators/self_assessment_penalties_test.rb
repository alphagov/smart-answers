require_relative "../../test_helper"

TEST_CALCULATOR_DATES = {
  :online_filing_deadline => {
    :"2011-12" => Date.new(2012, 1, 31)
  },
  :offline_filing_deadline => {
    :"2011-12" => Date.new(2011, 10, 31)
  },
  :payment_deadline => Date.new(2012, 1, 31),
  :penalty1date => Date.new(2012, 3, 2),
  :penalty2date => Date.new(2012, 8, 2),
  :penalty3date => Date.new(2013, 2, 2)
}

module SmartAnswer::Calculators
  class SelfAssessmentPenaltiesTest < ActiveSupport::TestCase
    def setup
      @calculator = SelfAssessmentPenalties.new(
        submission_method: "online", filing_date: "2012-01-10",
        payment_date: "2012-03-10", estimated_bill: SmartAnswer::Money.new(1200.5),
        dates: TEST_CALCULATOR_DATES,
        tax_year: :"2011-12"
      )
    end

    context "online submission" do
      context "filed and paid on time" do
        setup do
          @calculator.filing_date = "2012-01-10"
          @calculator.payment_date = "2012-01-10"
        end

        should "confirm payment was made on time" do
          assert @calculator.paid_on_time?
        end
      end

      context "filed or paid late" do
        should "confirm payment was made late" do
          refute @calculator.paid_on_time?
        end

        should "calculate late filing penalty" do
          # band one
          assert_equal 0, @calculator.late_filing_penalty
          # band two
          @calculator.filing_date = "2012-02-02"
          assert_equal 100, @calculator.late_filing_penalty
          # band three
          @calculator.filing_date = "2012-06-06"
          assert_equal 470, @calculator.late_filing_penalty
          # band four
          @calculator.filing_date = "2012-09-06"
          assert_equal 1300, @calculator.late_filing_penalty
          # band four (5% estimated bill larger than £300)
          @calculator.estimated_bill = SmartAnswer::Money.new(11000)
          assert_equal 1550, @calculator.late_filing_penalty
          # band five
          @calculator.filing_date = "2013-02-02"
          assert_equal 1600, @calculator.late_filing_penalty
          # band five (5% estimated bill larger than £600)
          @calculator.estimated_bill = SmartAnswer::Money.new(13000)
          assert_equal 1650, @calculator.late_filing_penalty
        end

        should "calculate interest payment" do
          @calculator.payment_date = "2012-01-01"
          assert_equal 0, @calculator.interest
          @calculator.payment_date = "2012-03-03"
          assert_equal 3.16, @calculator.interest
          # should calculate PenaltyInterest1
          @calculator.payment_date = "2012-04-02"
          @calculator.estimated_bill = SmartAnswer::Money.new(20000)
          assert_equal 102, @calculator.interest
          # should calculate PenaltyInterest2
          @calculator.payment_date = "2012-08-20"
          assert_equal 343.64, @calculator.interest
          # should calculate PenaltyInterest3
          @calculator.payment_date = "2013-02-20"
          assert_equal 675.37, @calculator.interest
        end

        should "calculate late payment penalty" do
          assert_equal 60.03, @calculator.late_payment_penalty
          @calculator.payment_date = "2012-08-03"
          assert_equal 120.05, @calculator.late_payment_penalty
          @calculator.payment_date = "2013-02-02"
          assert_equal 180.08, @calculator.late_payment_penalty
        end

        should "calculate total owed" do
          assert_equal 1264.38, @calculator.total_owed
          @calculator.payment_date = "2012-08-03"
          assert_equal 1339.42, @calculator.total_owed
          @calculator.payment_date = "2013-02-02"
          assert_equal 1419.17, @calculator.total_owed
        end
      end
    end

    context "offline submission" do
      setup do
        @calculator.submission_method = "paper"
      end
      context "filed and paid on time" do
        setup do
          @calculator.filing_date = "2011-10-30"
          @calculator.payment_date = "2012-01-10"
        end

        should "confirm payment was made on time" do
          assert @calculator.paid_on_time?
        end
      end

      context "filed or paid late" do
        setup do
          @calculator.filing_date = "2012-01-10"
          @calculator.payment_date = "2012-01-10"
        end
        should "confirm payment was made late" do
          refute @calculator.paid_on_time?
        end
      end
    end
  end
end