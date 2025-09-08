require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatePensionAgeCalculatorTest < ActiveSupport::TestCase
    context "#state_pension_date" do
      setup do
        @calculator = StatePensionAgeCalculator.new(
          gender: "male", dob: Date.parse("28 February 1961"),
        )
      end

      should "simply delegate to StatePensionDateQuery.state_pension_date" do
        assert_equal @calculator.state_pension_date,
                     StatePensionDateQuery.state_pension_date(@calculator.dob, @calculator.gender)
      end
    end

    context "#state_pension_age" do
      setup do
        @calculator = StatePensionAgeCalculator.new(
          gender: "male", dob: Date.parse("28 February 1961"),
        )
      end

      context "given a state_pension_date on a different year to the date of birth" do
        setup do
          @calculator.stubs(:state_pension_date).returns(Date.parse("28 Feb 2022"))
        end

        should "return the number of years to your state pension" do
          assert_equal @calculator.state_pension_age, "61 years"
        end
      end

      context "given a state_pension_date on a different year and month to the date of birth" do
        setup do
          @calculator.stubs(:state_pension_date).returns(Date.parse("28 March 2022"))
        end

        should "return the number of years to your state pension" do
          assert_equal @calculator.state_pension_age, "61 years, 1 month"
        end
      end

      context "given a state_pension_date on a different year, month and day to the date of birth" do
        setup do
          @calculator.stubs(:state_pension_date).returns(Date.parse("30 March 2022"))
        end

        should "return the number of years to your state pension" do
          assert_equal @calculator.state_pension_age, "61 years, 1 month, 2 days"
        end
      end

      context "given a state_pension_date on the 29th of Feb" do
        setup do
          @calculator.stubs(:dob).returns(Date.parse("29 Feb 1980"))
          @calculator.stubs(:state_pension_date).returns(Date.parse("1 March 2040"))
        end

        should "subtract one day from your state_pension age, and return number of years, months and days to your state pension" do
          assert_equal @calculator.state_pension_age, "60 years"
        end
      end

      context "given variable changes to state pension age between 66 - 67 years for births between 6 Apr 1960 - 5 Mar 1961" do
        [
          {
            birth_date: Date.parse("6 Apr 1960"),
            pension_date: Date.parse("6 May 2026"),
            expected_age: "66 years, 1 month",
          },
          {
            birth_date: Date.parse("20 May 1960"),
            pension_date: Date.parse("20 Jul 2026"),
            expected_age: "66 years, 2 months",
          },
          {
            birth_date: Date.parse("1 Jul 1960"),
            pension_date: Date.parse("1 Oct 2026"),
            expected_age: "66 years, 3 months",
          },
          {
            birth_date: Date.parse("8 Dec 1960"),
            pension_date: Date.parse("8 Sep 2027"),
            expected_age: "66 years, 9 months",
          },
          {
            birth_date: Date.parse("28 Feb 1961"),
            pension_date: Date.parse("28 Jan 2028"),
            expected_age: "66 years, 11 months",
          },
        ].each do |test_case|
          should "someone born on #{test_case[:birth_date]} and getting their pension on #{test_case[:pension_date]} should have a pension age of #{test_case[:age]}" do
            @calculator.stubs(:dob).returns(test_case[:birth_date])
            @calculator.stubs(:state_pension_date).returns(test_case[:pension_date])
            assert_equal test_case[:expected_age], @calculator.state_pension_age
          end
        end
      end

      context "given a series of dates around 28 Feb test the calculated state_pension_age" do
        [
          {
            birth_date: Date.parse("28 Feb 1980"),
            pension_date: Date.parse("28 Feb 2048"),
            expected_age: "68 years",
          },
          {
            birth_date: Date.parse("29 Feb 1980"),
            pension_date: Date.parse("29 Feb 2048"),
            expected_age: "68 years",
          },
          {
            birth_date: Date.parse("1 Mar 1980"),
            pension_date: Date.parse("1 Mar 2048"),
            expected_age: "68 years",
          },
          {
            birth_date: Date.parse("28 Feb 1981"),
            pension_date: Date.parse("28 Feb 2049"),
            expected_age: "68 years",
          },
          {
            birth_date: Date.parse("1 Mar 1981"),
            pension_date: Date.parse("1 Mar 2049"),
            expected_age: "68 years",
          },
        ].each do |test_case|
          should "someone born on #{test_case[:birth_date]} and getting their pension on #{test_case[:pension_date]} should have a pension age of #{test_case[:age]}" do
            @calculator.stubs(:dob).returns(test_case[:birth_date])
            @calculator.stubs(:state_pension_date).returns(test_case[:pension_date])
            assert_equal test_case[:expected_age], @calculator.state_pension_age
          end
        end
      end
    end

    context "#birthday_on_feb_29??" do
      should "be true for a date that is a the 29th of feb" do
        @calculator = StatePensionAgeCalculator.new(
          gender: "male", dob: Date.parse("29 February 1976"),
        )
        assert_equal true, @calculator.birthday_on_feb_29?
      end

      should "be false for a date that is not the 29th of feb" do
        @calculator = StatePensionAgeCalculator.new(
          gender: "male", dob: Date.parse("7 June 1960"),
        )
        assert_equal false, @calculator.birthday_on_feb_29?
      end
    end

    context "#pension_on_feb_29??" do
      context "pension due on 29th of Feb" do
        setup do
          @calculator = StatePensionAgeCalculator.new(
            gender: "male", dob: Date.parse("29 Feb 1980"),
          )
          @calculator.stubs(:state_pension_date).returns(Date.parse("29 Feb 2048"))
        end

        should "be true for a date that is the 29th of Feb" do
          assert @calculator.pension_on_feb_29?
        end
      end

      context "pension not due on 29th of Feb" do
        setup do
          @calculator = StatePensionAgeCalculator.new(
            gender: "male", dob: Date.parse("28 Aug 1974"),
          )
          @calculator.stubs(:state_pension_date).returns(Date.parse("28 Aug 2041"))
        end

        should "be false for a date that is not the 29th of Feb" do
          assert_not @calculator.pension_on_feb_29?
        end
      end
    end

    context "#before_state_pension_date?" do
      setup do
        @calculator = StatePensionAgeCalculator.new({})
      end

      should "return true for someone yet to reach their state pension date" do
        freeze_time do
          @calculator.stubs(:state_pension_date).returns(Time.zone.today + 1.day)
          assert @calculator.before_state_pension_date?
        end
      end

      should "return false for someone who has reached their state pension date" do
        freeze_time do
          @calculator.stubs(:state_pension_date).returns(Time.zone.today)
          assert_not @calculator.before_state_pension_date?
        end
      end

      should "return false for someone who has just passed their state pension date" do
        freeze_time do
          @calculator.stubs(:state_pension_date).returns(Time.zone.today - 1.day)
          assert_not @calculator.before_state_pension_date?
        end
      end
    end

    context "#before_state_pension_date?(days: 30)" do
      setup do
        @calculator = StatePensionAgeCalculator.new({})
      end

      should "return true for someone just over 30 days away from their pension_credit_date" do
        freeze_time do
          @calculator.stubs(:state_pension_date).returns(Time.zone.today + 31.days)
          assert @calculator.before_state_pension_date?(days: 2)
        end
      end

      should "return false for someone exactly 30 days away" do
        freeze_time do
          @calculator.stubs(:state_pension_date).returns(Time.zone.today + 30.days)
          assert_not @calculator.before_state_pension_date?(days: 30)
        end
      end

      should "return false for someone less than 30 days to their pension credit date" do
        freeze_time do
          @calculator.stubs(:state_pension_date).returns(Time.zone.today + 29.days)
          assert_not @calculator.before_state_pension_date?(days: 30)
        end
      end
    end

    context "#before_pension_credit_date?" do
      setup do
        @calculator = StatePensionAgeCalculator.new({})
      end

      should "return true for someone yet to reach their pension credit date" do
        freeze_time do
          @calculator.stubs(:pension_credit_date).returns(Time.zone.today + 1.day)
          assert @calculator.before_pension_credit_date?
        end
      end

      should "return false for someone has just reached their pension credit date" do
        freeze_time do
          @calculator.stubs(:pension_credit_date).returns(Time.zone.today)
          assert_not @calculator.before_pension_credit_date?
        end
      end

      should "return false for someone who has just passed their pension credit date" do
        freeze_time do
          @calculator.stubs(:pension_credit_date).returns(Time.zone.today - 1.day)
          assert_not @calculator.before_pension_credit_date?
        end
      end
    end

    context "#old_state_pension?" do
      setup do
        @calculator = StatePensionAgeCalculator.new({})
      end

      should "return true when the state_pension_date falls before 6 April 2016" do
        @calculator.stubs(:state_pension_date).returns(Date.parse("5 April 2016"))
        assert @calculator.old_state_pension?
      end

      should "return false when the state_pension_date falls on 6 April 2016" do
        @calculator.stubs(:state_pension_date).returns(Date.parse("6 April 2016"))
        assert_not @calculator.old_state_pension?
      end

      should "return false when the state_pension_date falls after 6 April 2016" do
        @calculator.stubs(:state_pension_date).returns(Date.parse("7 April 2016"))
        assert_not @calculator.old_state_pension?
      end
    end

    context "#over_16_years_old?" do
      should "be true for someone just older than 16" do
        freeze_time do
          date_of_birth = (16.years + 1.minute).ago

          calculator = StatePensionAgeCalculator.new(dob: date_of_birth)
          assert calculator.over_16_years_old?
        end
      end

      should "return false for someone exactly 16 years old" do
        freeze_time do
          date_of_birth = 16.years.ago

          calculator = StatePensionAgeCalculator.new(dob: date_of_birth)
          assert_not calculator.over_16_years_old?
        end
      end

      should "return false for someone just under 16 years old" do
        freeze_time do
          date_of_birth = (16.years - 1.minute).ago

          calculator = StatePensionAgeCalculator.new(dob: date_of_birth)
          assert_not calculator.over_16_years_old?
        end
      end
    end

    context "#can_apply?" do
      setup do
        @answers = { dob: Date.parse("1951-12-17") }
      end
      context "for women" do
        setup do
          @calculator = StatePensionAgeCalculator.new(@answers.merge(gender: "female"))
        end
        should "return true for a woman approaching state pension age (at 61 years, 10 months, 20 days) in 2 months time" do
          travel_to("2013-07-06") do
            assert @calculator.can_apply?
          end
        end

        should "return false for a woman approaching state pension age (at 61 years, 10 months, 20 days) in more than 2 months time" do
          travel_to("2013-07-05") do
            assert_not @calculator.can_apply?
          end
        end
      end

      context "for men" do
        setup do
          @calculator = StatePensionAgeCalculator.new(@answers.merge(gender: "male"))
        end
        should "return true for a man approaching pension age (at 65 years) in 2 months time" do
          travel_to("2016-10-17") do
            assert @calculator.can_apply?
          end
        end

        should "return false for a man approaching pension age (at 65 years) in more than 2 months time" do
          travel_to("2016-10-16") do
            assert_not @calculator.can_apply?
          end
        end
      end
    end

    context "#pension_age_based_on_gender?" do
      should "be true for a date that is before 06/12/1953" do
        @calculator = StatePensionAgeCalculator.new(dob: Date.parse("5 December 1953"))
        assert_equal true, @calculator.pension_age_based_on_gender?
      end

      should "be false for a date after 06/12/1953" do
        @calculator = StatePensionAgeCalculator.new(dob: Date.parse("6 December 1953"))
        assert_equal false, @calculator.pension_age_based_on_gender?
      end
    end
  end
end
