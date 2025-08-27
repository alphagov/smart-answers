require_relative "../../test_helper"

module SmartAnswer::Calculators
  class SelfAssessmentPenaltiesTest < ActiveSupport::TestCase
    def setup
      @calculator = SmartAnswer::Calculators::SelfAssessmentPenalties.new(
        submission_method: "online",
        filing_date: Date.parse("2024-01-10"),
        payment_date: Date.parse("2024-03-10"),
        estimated_bill: SmartAnswer::Money.new(5000),
        tax_year: "2022-23",
      )
    end

    context "#start_of_next_year" do
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
      should "return 2022-04-06 if tax-year is 2021-22" do
        @calculator.tax_year = "2021-22"

        assert_equal Date.new(2022, 4, 6), @calculator.start_of_next_tax_year
      end
      should "return 2023-04-06 if tax-year is 2022-23" do
        @calculator.tax_year = "2022-23"

        assert_equal Date.new(2023, 4, 6), @calculator.start_of_next_tax_year
      end
      should "return 2024-04-06 if tax-year is 2023-24" do
        @calculator.tax_year = "2023-24"

        assert_equal Date.new(2024, 4, 6), @calculator.start_of_next_tax_year
      end
    end

    context "one_year_after_start_date_for_penalties" do
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
      should "return 2024-02-01 if tax-year is 2021-22" do
        @calculator.tax_year = "2021-22"

        assert_equal Date.new(2024, 2, 1), @calculator.one_year_after_start_date_for_penalties
      end
      should "return 2025-02-01 if tax-year is 2022-23" do
        @calculator.tax_year = "2022-23"

        assert_equal Date.new(2025, 2, 1), @calculator.one_year_after_start_date_for_penalties
      end
      should "return 2026-02-01 if tax-year is 2023-24" do
        @calculator.tax_year = "2023-24"

        assert_equal Date.new(2026, 2, 1), @calculator.one_year_after_start_date_for_penalties
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
          @calculator.filing_date = Date.parse("2023-01-10")
          @calculator.payment_date = Date.parse("2023-01-10")

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
          @calculator.filing_date = Date.parse("2024-01-31")
          assert_equal 0, @calculator.late_filing_penalty

          # band one: 01 Feb - 29 April: incurs £100 penalty (<= 89 days)
          @calculator.filing_date = Date.parse("2024-02-01")
          assert_equal 1, @calculator.overdue_filing_days
          assert_equal 100, @calculator.late_filing_penalty
          @calculator.filing_date = Date.parse("2024-04-30")
          assert_equal 90, @calculator.overdue_filing_days
          assert_equal 110, @calculator.late_filing_penalty

          # band two: 1 May - 30 July: band one + £10/day (up to 90 days)
          # 1 day late incurs £10 penalty
          @calculator.filing_date = Date.parse("2024-05-01")
          assert_equal 91, @calculator.overdue_filing_days
          assert_equal 120, @calculator.late_filing_penalty
          # 3 days late incurs £30 penalty
          @calculator.filing_date = Date.parse("2024-05-03")
          assert_equal 93, @calculator.overdue_filing_days
          assert_equal 140, @calculator.late_filing_penalty
          # 90 days late incurs £900 penalty + band one
          @calculator.filing_date = Date.parse("2024-07-31")
          assert_equal 182, @calculator.overdue_filing_days
          assert_equal 1300, @calculator.late_filing_penalty

          # band three: 1 Aug - 31 Jan 2017: bands one + two + greater of £300 or 5% tax
          # > 181 days late incurs band two + £300
          @calculator.filing_date = Date.parse("2024-08-01")
          assert_equal 183, @calculator.overdue_filing_days
          assert_equal 1300, @calculator.late_filing_penalty
          # < 1 year late incurs band two + £300
          @calculator.filing_date = Date.parse("2025-01-31")
          assert_equal 366, @calculator.overdue_filing_days
          assert_equal 1600, @calculator.late_filing_penalty
          # > 181 days late incurs band two + 5% tax
          @calculator.estimated_bill = SmartAnswer::Money.new(10_000)
          @calculator.filing_date = Date.parse("2024-08-01")
          assert_equal 183, @calculator.overdue_filing_days
          assert_equal 1500, @calculator.late_filing_penalty
          # < 1 year days late incurs band two + 5% tax
          @calculator.filing_date = Date.parse("2025-01-31")
          assert_equal 366, @calculator.overdue_filing_days
          assert_equal 2000, @calculator.late_filing_penalty

          # band four: After 31 Jan 2017: band one + two + three + greater of £300 or 5% tax
          # > 1 year late incurs band three + £300
          @calculator.estimated_bill = SmartAnswer::Money.new(5_000)
          @calculator.filing_date = Date.parse("2025-02-01")
          assert_equal 367, @calculator.overdue_filing_days
          assert_equal 1600, @calculator.late_filing_penalty
          # > 1 year late incurs band three + 5% tax
          @calculator.estimated_bill = SmartAnswer::Money.new(10_000)
          @calculator.filing_date = Date.parse("2025-02-01")
          assert_equal 367, @calculator.overdue_filing_days
          assert_equal 2000, @calculator.late_filing_penalty
        end

        should "calculate total owed (excludes filing penalty)" do
          @calculator.payment_date = Date.parse("2024-02-02")
          assert_equal 5001, @calculator.total_owed
          @calculator.payment_date = Date.parse("2024-02-03")
          assert_equal 5002, @calculator.total_owed
          @calculator.payment_date = Date.parse("2024-08-03")
          assert_equal 5695, @calculator.total_owed
          @calculator.payment_date = Date.parse("2025-02-03")
          assert_equal 750, @calculator.late_payment_penalty
          assert_equal 6132, @calculator.total_owed
          @calculator.payment_date = Date.parse("2025-03-03")
          assert_equal 750, @calculator.late_payment_penalty
          assert_equal 6159, @calculator.total_owed
          @calculator.payment_date = Date.parse("2025-05-03")
          assert_equal 750, @calculator.late_payment_penalty
          assert_equal 6223, @calculator.total_owed
          @calculator.payment_date = Date.parse("2025-05-30")
          assert_equal 750, @calculator.late_payment_penalty
          assert_equal 6253, @calculator.total_owed
          @calculator.payment_date = Date.parse("2025-08-30")
          assert_equal 750, @calculator.late_payment_penalty
          assert_equal 6356, @calculator.total_owed
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
              assert_equal 21.58, @calculator.interest.to_f

              @calculator.payment_date = Date.parse("2022-04-01")
              assert_equal 0, @calculator.late_payment_penalty
              assert_equal 47.88, @calculator.interest.to_f
            end
          end

          context "late payment penalties after April 1st" do
            should "before April 5th, the user should have a late payment penalty of 3%" do
              @calculator.payment_date = Date.parse("2022-04-02")
              assert_equal 500, @calculator.late_payment_penalty
              assert_equal 48.70, @calculator.interest.to_f
            end

            should "after April 5th but before May 24th, the user should have a late payment penalty of 3.25%" do
              @calculator.payment_date = Date.parse("2022-04-05")
              assert_equal 500, @calculator.late_payment_penalty
              assert_equal 51.23, @calculator.interest.to_f
            end

            should "after May 24th, the user should have a late payment penalty of 3.5%" do
              @calculator.payment_date = Date.parse("2022-05-24")
              assert_equal 500, @calculator.late_payment_penalty
              assert_equal 94.86, @calculator.interest.to_f
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
          @calculator.filing_date = Date.parse("2022-10-30")
          @calculator.payment_date = Date.parse("2023-01-30")
        end

        should "confirm payment was made on time" do
          assert @calculator.paid_on_time?
        end
      end

      context "filed or paid late" do
        setup do
          @calculator.filing_date = Date.parse("2023-01-10")
          @calculator.payment_date = Date.parse("2024-02-01")
        end
        should "confirm payment was made late" do
          assert_not @calculator.paid_on_time?
        end
      end
    end

    context "late payment interest rates" do
      should "user should have a late payment penalty of 7.5% after August 19th 2024" do
        @calculator.payment_date = Date.parse("2024-08-20")
        assert_equal 500, @calculator.late_payment_penalty
        assert_equal 213.39, @calculator.interest.to_f
      end
    end
  end
end
