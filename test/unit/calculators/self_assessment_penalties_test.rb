require_relative "../../test_helper"

module SmartAnswer::Calculators
  class SelfAssessmentPenaltiesTest < ActiveSupport::TestCase
    def setup
      test_calculator_dates = {
        online_filing_deadline: {
          "2011-12": Date.new(2013, 1, 31),
          "2012-13": Date.new(2014, 1, 31),
          "2013-14": Date.new(2015, 1, 31),
        },
        offline_filing_deadline: {
          "2011-12": Date.new(2012, 10, 31),
          "2012-13": Date.new(2013, 10, 31),
          "2013-14": Date.new(2014, 10, 31),
        },
        payment_deadline: {
          "2011-12": Date.new(2013, 1, 31),
          "2012-13": Date.new(2014, 1, 31),
          "2013-14": Date.new(2015, 1, 31),
        },
      }

      @calculator = SelfAssessmentPenalties.new(
        submission_method: "online", filing_date: Date.parse("2013-01-10"),
        payment_date: Date.parse("2013-03-10"), estimated_bill: SmartAnswer::Money.new(5000),
        dates: test_calculator_dates,
        tax_year: :"2011-12"
      )
    end

    context "online submission" do
      context "filed and paid on time" do
        setup do
          @calculator.filing_date = Date.parse("2013-01-10")
          @calculator.payment_date = Date.parse("2013-01-10")
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
          @calculator.filing_date = Date.parse("2013-02-02")
          assert_equal 100, @calculator.late_filing_penalty
          # band two
          @calculator.filing_date = Date.parse("2013-05-01")
          assert_equal 110, @calculator.late_filing_penalty
          # band three
          @calculator.filing_date = Date.parse("2013-05-02")
          assert_equal 120, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2013-06-06")
          assert_equal 470, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2013-07-29")
          assert_equal 1000, @calculator.late_filing_penalty
          # band four
          @calculator.filing_date = Date.parse("2013-09-06")
          assert_equal 1300, @calculator.late_filing_penalty
          # band four (1000 + 5% of estimated bill larger than £300)
          @calculator.estimated_bill = SmartAnswer::Money.new(11000)
          assert_equal 1550, @calculator.late_filing_penalty
          # band five
          @calculator.estimated_bill = SmartAnswer::Money.new(0)
          @calculator.filing_date = Date.parse("2014-02-02")
          assert_equal 1600, @calculator.late_filing_penalty
          # band five (1000 + 5% estimated bill larger than £600)
          @calculator.estimated_bill = SmartAnswer::Money.new(10000)
          assert_equal 2000, @calculator.late_filing_penalty
          # from 6 to 12 months, tax <=6002
          @calculator.filing_date = Date.parse("2013-10-31")
          @calculator.estimated_bill = SmartAnswer::Money.new(10000)
          assert_equal 1500, @calculator.late_filing_penalty
          # from 6 to 12 months, tax >6002
          @calculator.filing_date = Date.parse("2013-10-31")
          @calculator.estimated_bill = SmartAnswer::Money.new(10000)
          assert_equal 1500, @calculator.late_filing_penalty
        end

        should "calculate interest and late payment penalty" do
          @calculator.estimated_bill = SmartAnswer::Money.new(10000)
          @calculator.payment_date = Date.parse("2013-01-01")
          assert_equal 0, @calculator.interest
          # 1 day after the deadling
          @calculator.payment_date = Date.parse("2013-02-01")
          assert_equal 0, @calculator.interest
          # 31 days after the deadline
          @calculator.payment_date = Date.parse("2013-03-03")
          assert_equal 24.66, @calculator.interest
          assert_equal 500, @calculator.late_payment_penalty
          # should calculate PenaltyInterest1
          @calculator.payment_date = Date.parse("2013-04-02")
          assert_equal 49.32, @calculator.interest #50.14 + 0.04 penalty interest
          # one day before late payment penalty 2
          @calculator.payment_date = Date.parse("2013-08-01")
          assert_equal 1000, @calculator.late_payment_penalty
          assert_equal 148.77, @calculator.interest
          # should calculate PenaltyInterest2
          @calculator.payment_date = Date.parse("2013-09-02")
          assert_equal 1000, @calculator.late_payment_penalty
          assert_equal 175.07, @calculator.interest
          # one day before late payment penalty 3
          @calculator.payment_date = Date.parse("2014-02-01")
          assert_equal 1500, @calculator.late_payment_penalty
          assert_equal 300, @calculator.interest
          # should apply late payment penalty 3
          @calculator.payment_date = Date.parse("2014-02-02")
          assert_equal 1500, @calculator.late_payment_penalty
          assert_equal 300.82, @calculator.interest
          # should calculate PenaltyInterest3
          @calculator.payment_date = Date.parse("2014-03-05")
          assert_equal 1500, @calculator.late_payment_penalty
          assert_equal 326.3, @calculator.interest
        end

        should "calculate total owed (excludes filing penalty)" do
          @calculator.payment_date = Date.parse("2013-02-02")
          assert_equal 5000, @calculator.total_owed
          @calculator.payment_date = Date.parse("2013-02-04")
          assert_equal 5001, @calculator.total_owed
          @calculator.payment_date = Date.parse("2013-08-01")
          assert_equal 5574, @calculator.total_owed
          @calculator.payment_date = Date.parse("2014-02-02")
          assert_equal 750, @calculator.late_payment_penalty
          assert_equal 5900, @calculator.total_owed
        end
      end # filed or paid late
    end # online submission

    context "offline submission" do
      setup do
        @calculator.submission_method = "paper"
      end
      context "filed and paid on time" do
        setup do
          @calculator.filing_date = Date.parse("2012-10-30")
          @calculator.payment_date = Date.parse("2013-01-30")
        end

        should "confirm payment was made on time" do
          assert @calculator.paid_on_time?
        end
      end

      context "filed or paid late" do
        setup do
          @calculator.filing_date = Date.parse("2012-01-10")
          @calculator.payment_date = Date.parse("2013-02-01")
        end
        should "confirm payment was made late" do
          refute @calculator.paid_on_time?
        end
      end
    end
  end
end
