require_relative "../../test_helper"

TEST_CALCULATOR_DATES = {
  :online_filing_deadline => {
    :"2011-12" => Date.new(2013, 1, 31),
    :"2012-13" => Date.new(2014, 1, 31)
  },
  :offline_filing_deadline => {
    :"2011-12" => Date.new(2012, 10, 31),
    :"2012-13" => Date.new(2013, 10, 31)
  },
  :payment_deadline => {
    :"2011-12" => Date.new(2013, 1, 31),
    :"2012-13" => Date.new(2014, 1, 31)
  },
  :penalty1date => {
    :"2011-12" => Date.new(2013, 3, 2),
    :"2012-13" => Date.new(2014, 3, 2)
  },
  :penalty2date => {
    :"2011-12" => Date.new(2013, 8, 2),
    :"2012-13" => Date.new(2014, 8, 2)
  },
  :penalty3date => {
    :"2011-12" => Date.new(2014, 2, 2),
    :"2012-13" => Date.new(2015, 2, 2)
  }
}

module SmartAnswer::Calculators
  class SelfAssessmentPenaltiesTest < ActiveSupport::TestCase
    def setup
      @calculator = SelfAssessmentPenalties.new(
        submission_method: "online", filing_date: "2013-01-10",
        payment_date: "2013-03-10", estimated_bill: SmartAnswer::Money.new(5000),
        dates: TEST_CALCULATOR_DATES,
        tax_year: :"2011-12"
      )
    end

    context "online submission" do
      context "filed and paid on time" do
        setup do
          @calculator.filing_date = "2013-01-10"
          @calculator.payment_date = "2013-01-10"
        end

        should "confirm payment was made on time" do
          assert @calculator.paid_on_time?
        end
      end # on time

      context "filed or paid late" do
        should "confirm payment was made late" do
          refute @calculator.paid_on_time?
        end

        should "calculate late filing penalty" do
          # band one
          assert_equal 0, @calculator.late_filing_penalty
          # band two
          @calculator.filing_date = "2013-02-02"
          assert_equal 100, @calculator.late_filing_penalty
          @calculator.filing_date = "2013-05-01"
          assert_equal 100, @calculator.late_filing_penalty
          # band three
          @calculator.filing_date = "2013-05-02"
          assert_equal 110, @calculator.late_filing_penalty
          @calculator.filing_date = "2013-06-06"
          assert_equal 460, @calculator.late_filing_penalty
          @calculator.filing_date = "2013-07-29"
          assert_equal 990, @calculator.late_filing_penalty
          # band four
          @calculator.filing_date = "2013-09-06"
          assert_equal 1300, @calculator.late_filing_penalty
          # band four (1000 + 5% of estimated bill larger than £300)
          @calculator.estimated_bill = SmartAnswer::Money.new(11000)
          assert_equal 1550, @calculator.late_filing_penalty
          # band five
          @calculator.filing_date = "2014-02-02"
          assert_equal 1600, @calculator.late_filing_penalty
          # band five (1000 + 5% estimated bill larger than £600)
          @calculator.estimated_bill = SmartAnswer::Money.new(13000)
          assert_equal 1650, @calculator.late_filing_penalty
        end

        should "calculate interest and late payment penalty" do
          @calculator.estimated_bill = SmartAnswer::Money.new(10000)
          @calculator.payment_date = "2013-01-01"
          assert_equal 0, @calculator.interest
          # 1 day after the deadling
          @calculator.payment_date = "2013-02-01"
          assert_equal 0.82, @calculator.interest
          # 31 days after the deadline
          @calculator.payment_date = "2013-03-03"
          assert_equal 25.48, @calculator.interest
          assert_equal 500, @calculator.late_payment_penalty
          # should calculate PenaltyInterest1
          @calculator.payment_date = "2013-04-02"
          assert_equal 50.18, @calculator.interest #50.14 + 0.04 penalty interest
          # one day before late payment penalty 2
          @calculator.payment_date = "2013-08-01"
          assert_equal 500, @calculator.late_payment_penalty
          assert_equal 154.60, @calculator.interest
          # should calculate PenaltyInterest2
          @calculator.payment_date = "2013-09-02"
          assert_equal 1000, @calculator.late_payment_penalty
          assert_equal 182.26, @calculator.interest
          # one day before late payment penalty 3
          @calculator.payment_date = "2014-02-01"
          assert_equal 1000, @calculator.late_payment_penalty
          assert_equal 319.68, @calculator.interest
          # should apply late payment penalty 3
          @calculator.payment_date = "2014-02-02"
          assert_equal 1500, @calculator.late_payment_penalty
          assert_equal 320.59, @calculator.interest
          # should calculate PenaltyInterest3
          @calculator.payment_date = "2014-03-05"
          assert_equal 1500, @calculator.late_payment_penalty
          assert_equal 348.66, @calculator.interest
        end


        should "calculate total owed (excludes filing penalty)" do
          @calculator.payment_date = "2013-02-02"
          assert_equal 5000, @calculator.total_owed #0.82 before flooring
          @calculator.payment_date = "2013-02-03"
          assert_equal 5001, @calculator.total_owed #1.64 before flooring
          @calculator.payment_date = "2013-08-01"
          assert_equal 5327, @calculator.total_owed #327.30 before flooring
          @calculator.payment_date = "2014-02-02"
          assert_equal 750, @calculator.late_payment_penalty
          assert_equal 5910, @calculator.total_owed #750 + 160.29 interest
        end

      end # filed or paid late
    end # online submission

    context "offline submission" do
      setup do
        @calculator.submission_method = "paper"
      end
      context "filed and paid on time" do
        setup do
          @calculator.filing_date = "2012-10-30"
          @calculator.payment_date = "2013-01-30"
        end

        should "confirm payment was made on time" do
          assert @calculator.paid_on_time?
        end
      end

      context "filed or paid late" do
        setup do
          @calculator.filing_date = "2012-01-10"
          @calculator.payment_date = "2013-02-01"
        end
        should "confirm payment was made late" do
          refute @calculator.paid_on_time?
        end
      end
    end
  end
end