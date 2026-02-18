require_relative "../test_helper"
require "ostruct"

module SmartAnswer
  class DateQuestionTest < ActiveSupport::TestCase
    def setup
      @initial_state = State.new(:example)
    end

    context "#parse_input" do
      setup do
        @question = Question::Date.new(nil, :example)
      end

      context "when supplied with a hash" do
        should "return a date representing the hash" do
          date = @question.parse_input(day: 1, month: 2, year: 2015)
          assert_equal Date.parse("2015-02-01"), date
        end

        should "raise an InvalidResponse exception when the hash represents an invalid date" do
          assert_raises(InvalidResponse) do
            @question.parse_input(day: 32, month: 2, year: 2015)
          end
        end

        should "raise an InvalidResponse exception when the hash represents an invalid date with negatives" do
          assert_raises(InvalidResponse) do
            @question.parse_input(day: -2, month: 2, year: 2015)
          end
        end

        context "and the day is missing" do
          should "raise an InvalidResponse exception" do
            assert_raises(InvalidResponse) do
              @question.parse_input(day: nil, month: 2, year: 2015)
            end
          end

          should "return the date using the default day when specified" do
            @question.default_day { 1 }
            date = @question.parse_input(day: nil, month: 2, year: 2015)
            assert_equal Date.parse("2015-02-01"), date
          end
        end

        context "and the month is missing" do
          should "raise an InvalidResponse exception" do
            assert_raises(InvalidResponse) do
              @question.parse_input(day: 1, month: nil, year: 2015)
            end
          end

          should "return the date using the default month when specified" do
            @question.default_month { 2 }
            date = @question.parse_input(day: 1, month: nil, year: 2015)
            assert_equal Date.parse("2015-02-01"), date
          end
        end

        context "and the year is missing" do
          should "raise an InvalidResponse exception" do
            assert_raises(InvalidResponse) do
              @question.parse_input(day: 1, month: 2, year: nil)
            end
          end

          should "return the date using the default year when specified" do
            @question.default_year { 2015 }
            date = @question.parse_input(day: 1, month: 2, year: nil)
            assert_equal Date.parse("2015-02-01"), date
          end
        end
      end

      context "when supplied with a string" do
        should "return a date representing the string" do
          date = @question.parse_input("2015-02-01")
          assert_equal Date.parse("2015-02-01"), date
        end

        should "raise an InvalidResponse exception when the string represents an invalid date" do
          assert_raises(InvalidResponse) do
            @question.parse_input("2015-02-32")
          end
        end
      end

      context "when supplied with a date" do
        should "return the date" do
          date = @question.parse_input(Date.parse("2015-02-01"))
          assert_equal Date.parse("2015-02-01"), date
        end
      end

      context "when supplied with another object" do
        should "raise an InvalidResponse exception" do
          assert_raises(InvalidResponse) do
            @question.parse_input(Object.new)
          end
        end
      end
    end

    test "dates are parsed from Hash into Date before being saved" do
      q = Question::Date.new(nil, :example) do
        on_response do |response|
          self.date = response
        end

        next_node { outcome :done }
      end

      new_state = q.transition(@initial_state, year: "2011", month: "2", day: "1")
      assert_equal Date.parse("2011-02-01"), new_state.date
    end

    test "incomplete dates raise an error" do
      q = Question::Date.new(nil, :example) do
        on_response do |response|
          self.date = response
        end

        next_node { outcome :done }
      end

      assert_raise SmartAnswer::InvalidResponse do
        q.transition(@initial_state, year: "", month: "2", day: "1")
      end
    end

    test "rejects dates before a specified from date" do
      question = Question::Date.new(nil, :example) do
        from { Date.parse("2021-08-01") }
        next_node { outcome :done }
      end

      assert_raises(InvalidResponse) do
        question.transition(@initial_state, "2021-07-31")
      end
    end

    test "accepts dates equal to the specified from date" do
      question = Question::Date.new(nil, :example) do
        from { Date.parse("2021-08-01") }
        next_node { outcome :done }
      end

      new_state = question.transition(@initial_state, "2021-08-01")
      assert @initial_state != new_state
    end

    test "accepts dates greater than the specified from date" do
      question = Question::Date.new(nil, :example) do
        from { Date.parse("2021-08-01") }
        next_node { outcome :done }
      end

      new_state = question.transition(@initial_state, "2021-08-02")
      assert @initial_state != new_state
    end

    test "rejects dates after a specified to date" do
      question = Question::Date.new(nil, :example) do
        to { Date.parse("2021-08-01") }
        next_node { outcome :done }
      end

      assert_raises(InvalidResponse) do
        question.transition(@initial_state, "2021-08-02")
      end
    end

    test "accepts dates equal to the specified to date" do
      question = Question::Date.new(nil, :example) do
        to { Date.parse("2021-08-01") }
        next_node { outcome :done }
      end

      new_state = question.transition(@initial_state, "2021-08-01")
      assert @initial_state != new_state
    end

    test "accepts dates less than the specified to date" do
      question = Question::Date.new(nil, :example) do
        to { Date.parse("2021-08-01") }
        next_node { outcome :done }
      end

      new_state = question.transition(@initial_state, "2021-07-31")
      assert @initial_state != new_state
    end

    test "raises an error when date validation is misconfigured to block flow progression" do
      question = Question::Date.new(nil, :example) do
        to { Date.parse("2021-08-01") }
        from { Date.parse("2021-08-03") }
        next_node { outcome :done }
      end

      exception = assert_raise RuntimeError do
        question.transition(@initial_state, "2021-08-02")
      end

      assert "from date must not be after the to date", exception.message
    end

    test "define default day" do
      q = Question::Date.new(nil, :example) do
        default_day { 11 }
      end
      assert_equal 11, q.default_day
    end

    test "define default month" do
      q = Question::Date.new(nil, :example) do
        default_month { 2 }
      end
      assert_equal 2, q.default_month
    end

    test "define default year" do
      q = Question::Date.new(nil, :example) do
        default_year { 2013 }
      end
      assert_equal 2013, q.default_year
    end

    test "incomplete dates are accepted if appropriate defaults are defined" do
      q = Question::Date.new(nil, :example) do
        default_day { 11 }
        default_month { 2 }
        default_year { 2013 }
        on_response do |response|
          self.date = response
        end

        next_node { outcome :done }
      end

      new_state = q.transition(@initial_state, year: "", month: "", day: "")
      assert_equal Date.parse("2013-02-11"), new_state.date
    end

    test "default the day to the last in the month of an incomplete date" do
      q = Question::Date.new(nil, :example) do
        default_day { -1 }
        on_response do |response|
          self.date = response
        end

        next_node { outcome :done }
      end

      incomplete_date = { year: "2013", month: "2", day: "" }
      new_state = q.transition(@initial_state, incomplete_date)
      assert_equal Date.parse("2013-02-28"), new_state.date
    end

    test "#date_of_birth_defaults prevent very old values" do
      assert_raise SmartAnswer::InvalidResponse do
        dob_question.transition(@initial_state, 125.years.ago.to_date.to_s)
      end
    end

    test "#date_of_birth_defaults prevent next year dates" do
      assert_raise SmartAnswer::InvalidResponse do
        next_year_start = 1.year.from_now.beginning_of_year.to_date.to_s
        dob_question.transition(@initial_state, next_year_start)
      end
    end

    test "#date_of_birth_defaults accepts 120 years old values" do
      dob_question.transition(@initial_state, 120.years.ago.to_date.to_s)
    end

  private

    def dob_question
      Question::Date.new(nil, :example) do
        date_of_birth_defaults
        on_response do |response|
          self.date = response
        end

        next_node { outcome :done }
      end
    end
  end
end
