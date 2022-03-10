require_relative "../../test_helper"

module SmartAnswer::Calculators
  class SelfAssessmentPenaltiesTest < ActiveSupport::TestCase
    def setup
      @calculator = SelfAssessmentPenalties.new(
        submission_method: "online",
        filing_date: Date.parse("2016-01-10"),
        payment_date: Date.parse("2016-03-10"),
        estimated_bill: SmartAnswer::Money.new(5000),
        tax_year: "2014-15",
      )
    end

    context "#start_of_next_year" do
      should "return 2015-04-06 if tax-year is 2014-15" do
        @calculator.tax_year = "2014-15"

        assert_equal Date.new(2015, 4, 6), @calculator.start_of_next_tax_year
      end
      should "return 2016-04-06 if tax-year is 2016-15" do
        @calculator.tax_year = "2015-16"

        assert_equal Date.new(2016, 4, 6), @calculator.start_of_next_tax_year
      end
      should "return 2017-04-06 if tax-year is 2017-17" do
        @calculator.tax_year = "2016-17"

        assert_equal Date.new(2017, 4, 6), @calculator.start_of_next_tax_year
      end
      should "return 2018-04-06 if tax-year is 2017-18" do
        @calculator.tax_year = "2017-18"

        assert_equal Date.new(2018, 4, 6), @calculator.start_of_next_tax_year
      end
      should "return 2019-04-06 if tax-year is 2018-19" do
        @calculator.tax_year = "2018-19"

        assert_equal Date.new(2019, 4, 6), @calculator.start_of_next_tax_year
      end
      should "return 2020-04-06 if tax-year is 2019-20" do
        @calculator.tax_year = "2019-20"

        assert_equal Date.new(2020, 4, 6), @calculator.start_of_next_tax_year
      end
      should "return 2021-04-06 if tax-year is 2020-21" do
        @calculator.tax_year = "2020-21"

        assert_equal Date.new(2021, 4, 6), @calculator.start_of_next_tax_year
      end
    end

    context "one_year_after_start_date_for_penalties" do
      should "return 2017-02-01 if tax-year is 2014-15" do
        @calculator.tax_year = "2014-15"

        assert_equal Date.new(2017, 2, 1), @calculator.one_year_after_start_date_for_penalties
      end
      should "return 2018-02-01 if tax-year is 2015-16" do
        @calculator.tax_year = "2015-16"

        assert_equal Date.new(2018, 2, 1), @calculator.one_year_after_start_date_for_penalties
      end
      should "return 2019-02-01 if tax-year is 2016-17" do
        @calculator.tax_year = "2016-17"

        assert_equal Date.new(2019, 2, 1), @calculator.one_year_after_start_date_for_penalties
      end
      should "return 2020-02-01 if tax-year is 2017-18" do
        @calculator.tax_year = "2017-18"

        assert_equal Date.new(2020, 2, 1), @calculator.one_year_after_start_date_for_penalties
      end
      should "return 2021-02-01 if tax-year is 2018-19" do
        @calculator.tax_year = "2018-19"

        assert_equal Date.new(2021, 2, 1), @calculator.one_year_after_start_date_for_penalties
      end
      should "return 2022-02-01 if tax-year is 2019-20" do
        @calculator.tax_year = "2019-20"

        assert_equal Date.new(2022, 2, 1), @calculator.one_year_after_start_date_for_penalties
      end
      should "return 2023-02-01 if tax-year is 2020-21" do
        @calculator.tax_year = "2020-21"

        assert_equal Date.new(2023, 2, 1), @calculator.one_year_after_start_date_for_penalties
      end
    end

    context "valid_filing_date?" do
      should "be valid if filing date is on or after start of next tax year" do
        @calculator.filing_date = @calculator.start_of_next_tax_year
        assert @calculator.valid_filing_date?
      end

      should "be invalid if filing date is before start of next tax year" do
        @calculator.filing_date = @calculator.start_of_next_tax_year - 1.day
        assert_not @calculator.valid_filing_date?
      end
    end

    context "valid_payment_date?" do
      should "be valid if payment date is before filing date for tax year 2019-20" do
        @calculator.tax_year = "2019-20"
        @calculator.payment_date = @calculator.filing_date - 1.day
        assert @calculator.valid_payment_date?
      end

      should "be valid if payment date is on or after filing date" do
        @calculator.payment_date = @calculator.filing_date
        assert @calculator.valid_payment_date?
      end

      should "be invalid if filing date is before filing date" do
        @calculator.payment_date = @calculator.filing_date - 1.day
        assert_not @calculator.valid_payment_date?
      end
    end

    context "online submission" do
      context "filed and paid on time" do
        should "confirm payment was made on time" do
          @calculator.filing_date = Date.parse("2015-01-10")
          @calculator.payment_date = Date.parse("2015-01-10")

          assert @calculator.paid_on_time?
        end

        should "confirm payment was made on time for tax year 2019-20" do
          @calculator.tax_year = "2019-20"
          @calculator.filing_date = Date.parse("2020-02-28")
          @calculator.payment_date = Date.parse("2020-01-31")

          assert @calculator.paid_on_time?
        end
      end # on time

      context "filed or paid late" do
        should "confirm payment was made late" do
          assert_not @calculator.paid_on_time?
        end

        should "calculate late filing penalty for tax year 2019-20 - special rules for Covid" do
          @calculator.tax_year = "2019-20"
          # Filing Deadline is Feb 28 this year rather than Jan 31
          # Additional 28 days to file due to covid-19
          # band 0: before 01 March incurs £0 penalty
          @calculator.filing_date = Date.parse("2021-02-28")
          assert_equal 0, @calculator.late_filing_penalty
          # band one: 01 March - 30 April: incurs £100 penalty
          # £100 penalty
          @calculator.filing_date = Date.parse("2021-03-01")
          assert_equal 100, @calculator.late_filing_penalty
          # £100 penalty
          @calculator.filing_date = Date.parse("2021-04-30")
          assert_equal 100, @calculator.late_filing_penalty
          # band two: 01 May - 31 July: band one + £10/day (up to 90 days)
          # 1 day late incurs £10 penalty
          @calculator.filing_date = Date.parse("2021-05-01")
          assert_equal 110, @calculator.late_filing_penalty
          # 3 days late incurs £30 penalty
          @calculator.filing_date = Date.parse("2021-05-03")
          assert_equal 130, @calculator.late_filing_penalty
          # 90 days late incurs £900 penalty
          @calculator.filing_date = Date.parse("2021-07-31")
          assert_equal 1000, @calculator.late_filing_penalty
          # band three: 31 July - 31 Jan 2022: bands one + two + greater of £300 or 5% tax
          # £300
          @calculator.filing_date = Date.parse("2021-08-01")
          assert_equal 1300, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2022-01-31")
          assert_equal 1300, @calculator.late_filing_penalty
          # 5% tax
          @calculator.estimated_bill = SmartAnswer::Money.new(10_000)
          @calculator.filing_date = Date.parse("2021-08-01")
          assert_equal 1500, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2022-01-31")
          assert_equal 1500, @calculator.late_filing_penalty
          # band four: After 31 Jan 2022: band one + two + three + greater of £300 or 5% tax
          # £300
          @calculator.estimated_bill = SmartAnswer::Money.new(5_000)
          @calculator.filing_date = Date.parse("2022-02-01")
          assert_equal 1600, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2022-02-01")
          assert_equal 1600, @calculator.late_filing_penalty
          # 5% tax
          @calculator.estimated_bill = SmartAnswer::Money.new(10_000)
          @calculator.filing_date = Date.parse("2022-02-01")
          assert_equal 2000, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2022-02-01")
          assert_equal 2000, @calculator.late_filing_penalty
        end

        should "calculate late filing penalty for tax year 2020-21 - special rules for Covid" do
          @calculator.tax_year = "2020-21"
          # Filing Deadline is Feb 28 this year rather than Jan 31
          # Additional 28 days to file due to covid-19

          # band 0: before 01 March incurs £0 penalty
          @calculator.filing_date = Date.parse("2022-02-28")
          assert_equal 0, @calculator.late_filing_penalty

          # band one: 01 March - 30 April: incurs £100 penalty
          # £100 penalty
          @calculator.filing_date = Date.parse("2022-03-01")
          assert_equal 100, @calculator.late_filing_penalty
          # £100 penalty
          @calculator.filing_date = Date.parse("2022-04-30")
          assert_equal 100, @calculator.late_filing_penalty
          # band two: 01 May - 31 July: band one + £10/day (up to 90 days)
          # 1 day late incurs £10 penalty
          @calculator.filing_date = Date.parse("2022-05-01")
          assert_equal 110, @calculator.late_filing_penalty
          # 3 days late incurs £30 penalty
          @calculator.filing_date = Date.parse("2022-05-03")
          assert_equal 130, @calculator.late_filing_penalty
          # 90 days late incurs £900 penalty
          @calculator.filing_date = Date.parse("2022-07-31")
          assert_equal 1000, @calculator.late_filing_penalty
          # band three: 31 July - 31 Jan 2023: bands one + two + greater of £300 or 5% tax
          # £300
          @calculator.filing_date = Date.parse("2022-08-01")
          assert_equal 1300, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2023-01-31")
          assert_equal 1300, @calculator.late_filing_penalty
          # 5% tax
          @calculator.estimated_bill = SmartAnswer::Money.new(10_000)
          @calculator.filing_date = Date.parse("2022-08-01")
          assert_equal 1500, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2023-01-31")
          assert_equal 1500, @calculator.late_filing_penalty
          # band four: After 31 Jan 2023: band one + two + three + greater of £300 or 5% tax
          # £300
          @calculator.estimated_bill = SmartAnswer::Money.new(5_000)
          @calculator.filing_date = Date.parse("2023-02-01")
          assert_equal 1600, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2023-02-01")
          assert_equal 1600, @calculator.late_filing_penalty
          # 5% tax
          @calculator.estimated_bill = SmartAnswer::Money.new(10_000)
          @calculator.filing_date = Date.parse("2023-02-01")
          assert_equal 2000, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2023-02-01")
          assert_equal 2000, @calculator.late_filing_penalty
        end

        should "calculate late filing penalty" do
          # band 0: No penalty by 31 January for previous tax year
          @calculator.filing_date = Date.parse("2016-01-31")
          assert_equal 0, @calculator.late_filing_penalty

          # band one: 01 Feb - 29 April: incurs £100 penalty (<= 89 days)
          @calculator.filing_date = Date.parse("2016-02-01")
          assert_equal 1, @calculator.overdue_filing_days
          assert_equal 100, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2016-04-29")
          assert_equal 89, @calculator.overdue_filing_days
          assert_equal 100, @calculator.late_filing_penalty

          # band two: 30 April - 30 July: band one + £10/day (up to 90 days)
          # 1 day late incurs £10 penalty
          @calculator.filing_date = Date.parse("2016-04-30")
          assert_equal 90, @calculator.overdue_filing_days
          assert_equal 110, @calculator.late_filing_penalty
          # 3 days late incurs £30 penalty
          @calculator.filing_date = Date.parse("2016-05-02")
          assert_equal 92, @calculator.overdue_filing_days
          assert_equal 130, @calculator.late_filing_penalty
          # 90 days late incurs £900 penalty + band one
          @calculator.filing_date = Date.parse("2016-07-30")
          assert_equal 181, @calculator.overdue_filing_days
          assert_equal 1000, @calculator.late_filing_penalty

          # band three: 31 July - 31 Jan 2017: bands one + two + greater of £300 or 5% tax
          # > 181 days late incurs band two + £300
          @calculator.filing_date = Date.parse("2016-07-31")
          assert_equal 182, @calculator.overdue_filing_days
          assert_equal 1300, @calculator.late_filing_penalty
          # < 366 days late incurs band two + £300
          @calculator.filing_date = Date.parse("2017-01-30")
          assert_equal 365, @calculator.overdue_filing_days
          assert_equal 1300, @calculator.late_filing_penalty
          # > 181 days late incurs band two + 5% tax
          @calculator.estimated_bill = SmartAnswer::Money.new(10_000)
          @calculator.filing_date = Date.parse("2016-07-31")
          assert_equal 182, @calculator.overdue_filing_days
          assert_equal 1500, @calculator.late_filing_penalty
          # < 366 days late incurs band two + 5% tax
          @calculator.filing_date = Date.parse("2017-01-30")
          assert_equal 365, @calculator.overdue_filing_days
          assert_equal 1500, @calculator.late_filing_penalty

          # band four: After 31 Jan 2017: band one + two + three + greater of £300 or 5% tax
          # > 365 days late incurs band three + £300
          @calculator.estimated_bill = SmartAnswer::Money.new(5_000)
          @calculator.filing_date = Date.parse("2017-01-31")
          assert_equal 366, @calculator.overdue_filing_days
          assert_equal 1600, @calculator.late_filing_penalty
          # > 365 days late incurs band three + 5% tax
          @calculator.estimated_bill = SmartAnswer::Money.new(10_000)
          @calculator.filing_date = Date.parse("2017-01-31")
          assert_equal 366, @calculator.overdue_filing_days
          assert_equal 2000, @calculator.late_filing_penalty
        end

        context "pay penalty before rate change on 23 Aug 2016" do
          should "calculate interest and late payment penalty" do
            @calculator.estimated_bill = SmartAnswer::Money.new(10_000)
            @calculator.payment_date = Date.parse("2016-01-01")
            assert_equal 0, @calculator.interest
            # 1 day after the deadline
            @calculator.payment_date = Date.parse("2016-02-01")
            assert_equal 1, @calculator.overdue_payment_days
            assert_equal 0, @calculator.interest
            # 31 days after the deadline
            @calculator.payment_date = Date.parse("2016-03-02")
            assert_equal 31, @calculator.overdue_payment_days
            assert_equal 26.71, @calculator.interest
            assert_equal 500, @calculator.late_payment_penalty
            # > 60 days late should calculate PenaltyInterest1
            @calculator.payment_date = Date.parse("2016-04-01")
            assert_equal 61, @calculator.overdue_payment_days
            assert_equal 500, @calculator.late_payment_penalty
            assert_equal 53.42, @calculator.interest # 50.14 + 0.04 penalty interest
            # 183 days late, one day before late payment penalty 2
            @calculator.payment_date = Date.parse("2016-08-01")
            assert_equal 183, @calculator.overdue_payment_days
            assert_equal 500, @calculator.late_payment_penalty
            assert_equal 162.05, @calculator.interest
            # > 183 days late, should calculate PenaltyInterest2
            @calculator.payment_date = Date.parse("2016-08-02")
            assert_equal 184, @calculator.overdue_payment_days
            assert_equal 1000, @calculator.late_payment_penalty
            assert_equal 162.95, @calculator.interest
            # 214 days late, should calculate PenaltyInterest2
            @calculator.payment_date = Date.parse("2016-09-01")
            assert_equal 214, @calculator.overdue_payment_days
            assert_equal 1000, @calculator.late_payment_penalty
            assert_equal 189.66, @calculator.interest
            # 367 days late, one day before late payment penalty 3
            @calculator.payment_date = Date.parse("2017-02-01")
            assert_equal 367, @calculator.overdue_payment_days
            assert_equal 1000, @calculator.late_payment_penalty
            assert_equal 325.89, @calculator.interest
            # > 367 days late, should apply late payment penalty 3
            @calculator.payment_date = Date.parse("2017-02-02")
            assert_equal 368, @calculator.overdue_payment_days
            assert_equal 1500, @calculator.late_payment_penalty
            assert_equal 326.78, @calculator.interest
            # 398 days late, should calculate PenaltyInterest3
            @calculator.payment_date = Date.parse("2017-03-04")
            assert_equal 398, @calculator.overdue_payment_days
            assert_equal 1500, @calculator.late_payment_penalty
            assert_equal 353.49, @calculator.interest
          end

          should "calculate total owed (excludes filing penalty)" do
            @calculator.payment_date = Date.parse("2016-02-02")
            assert_equal 5000, @calculator.total_owed
            @calculator.payment_date = Date.parse("2016-02-04")
            assert_equal 5001, @calculator.total_owed
            @calculator.payment_date = Date.parse("2016-08-03")
            assert_equal 5581, @calculator.total_owed
            @calculator.payment_date = Date.parse("2017-02-03")
            assert_equal 750, @calculator.late_payment_penalty
            assert_equal 5913, @calculator.total_owed
          end
        end

        context "HMRC Covid-19 Extension to 1 April for 2019-20" do
          setup do
            @calculator.tax_year = "2019-20"
            @calculator.submission_method = "online"
            @calculator.filing_date = Date.parse("2021-01-31")
            @calculator.estimated_bill = SmartAnswer::Money.new(10_000)
          end

          context "the user has to pay interest on their debt if they pay between 31st Jan and 1st April - but no penalty" do
            should "be no interest incurred prior to 31st Jan" do
              @calculator.payment_date = Date.parse("2021-01-31")
              assert_equal 0, @calculator.late_payment_penalty
              assert_equal 0.0, @calculator.interest.to_f
            end

            should "incur interest payments between 31st Jan and 1st April" do
              @calculator.payment_date = Date.parse("2021-02-01")
              assert_equal 0, @calculator.late_payment_penalty
              assert_equal 0.71, @calculator.interest.to_f

              @calculator.payment_date = Date.parse("2021-04-01")
              assert_equal 0, @calculator.late_payment_penalty
              assert_equal 42.74, @calculator.interest.to_f
            end
          end

          should "the user should have a late payment penalty as they are beyond the new deadline of 2nd April" do
            @calculator.payment_date = Date.parse("2021-04-02")
            assert_equal 500, @calculator.late_payment_penalty
            assert_equal 43.45, @calculator.interest.to_f
          end
        end

        context "HMRC Covid-19 Extension to 1 April for 2020-21" do
          setup do
            @calculator.tax_year = "2020-21"
            @calculator.submission_method = "online"
            @calculator.filing_date = Date.parse("2022-01-31")
            @calculator.estimated_bill = SmartAnswer::Money.new(10_000)
          end

          context "the user has to pay interest on their debt if they pay between 31st Jan and 2nd Apr - but no penalty" do
            should "be no interest incurred prior to 31st Jan" do
              @calculator.payment_date = Date.parse("2022-01-31")
              assert_equal 0, @calculator.late_payment_penalty
              assert_equal 0.0, @calculator.interest.to_f
            end

            should "incur interest payments between 31st Jan and 2nd Apr" do
              @calculator.payment_date = Date.parse("2022-02-01")
              assert_equal 0, @calculator.late_payment_penalty
              assert_equal 0.75, @calculator.interest.to_f

              @calculator.payment_date = Date.parse("2022-02-28")
              assert_equal 0, @calculator.late_payment_penalty
              assert_equal 21.1, @calculator.interest.to_f

              @calculator.payment_date = Date.parse("2022-04-01")
              assert_equal 0, @calculator.late_payment_penalty
              assert_equal 45.21, @calculator.interest.to_f
            end
          end

          should "the user should have a late payment penalty as they are beyond the new deadline of 1st of April" do
            @calculator.payment_date = Date.parse("2022-04-02")
            assert_equal 500, @calculator.late_payment_penalty
            assert_equal 45.96, @calculator.interest.to_f
          end
        end

        context "pay penalty after rate change on 23 Aug 2016" do
          setup do
            @calculator.estimated_bill = SmartAnswer::Money.new(1000)
          end

          context "deadline and payment dates are before rate change date" do
            should "have values with rate at 3%" do
              @calculator.payment_deadline = Date.parse("2016-01-31")
              @calculator.payment_date = Date.parse("2016-08-23")
              assert_equal 18.16, @calculator.interest.value.to_f
            end
          end

          context "deadline and payment dates are after rate change date" do
            should "have values from rate at 2.75%" do
              @calculator.payment_deadline = Date.parse("2016-08-23")
              @calculator.payment_date = Date.parse("2016-10-31")
              assert_equal 6.05, @calculator.interest.value.to_f
            end
          end

          context "tax year includes rate change, deadline and payment are after rate change" do
            should "should have value from rate at 2.75%" do
              @calculator.tax_year = "2015-16"
              @calculator.payment_deadline = Date.parse("2017-1-31")
              @calculator.payment_date = Date.parse("2017-3-1")
              assert_equal 2.49, @calculator.interest.value.to_f
            end
          end

          context "deadline is before rate change date, payment is after rate change date" do
            should "have value calculated with rates from before and after change" do
              @calculator.payment_deadline = Date.parse("2016-01-31")
              @calculator.payment_date = Date.parse("2016-10-31")
              assert_equal 24.31, @calculator.interest.value.to_f
            end
          end
        end
      end # filed or paid late
    end # online submission

    context "offline submission" do
      setup do
        @calculator.submission_method = "paper"
      end

      context "filed during Covid easement" do
        setup do
          @calculator.filing_date = Date.parse("2021-01-28")
        end

        should "not benefit from the extended deadline" do
          assert_not @calculator.paid_on_time?
        end
      end

      context "filed and paid on time" do
        setup do
          @calculator.filing_date = Date.parse("2014-10-30")
          @calculator.payment_date = Date.parse("2015-01-30")
        end

        should "confirm payment was made on time" do
          assert @calculator.paid_on_time?
        end
      end

      context "filed or paid late" do
        setup do
          @calculator.filing_date = Date.parse("2015-01-10")
          @calculator.payment_date = Date.parse("2016-02-01")
        end
        should "confirm payment was made late" do
          assert_not @calculator.paid_on_time?
        end
      end
    end
  end
end
