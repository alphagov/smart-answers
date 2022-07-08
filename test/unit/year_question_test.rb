require_relative "../test_helper"
require "ostruct"

module SmartAnswer
  class YearQuestionTest < ActiveSupport::TestCase
    def setup
      @initial_state = State.new(:example)
    end

    context "#parse_input" do
      setup do
        @question = Question::Year.new(nil, :example)
      end

      context "when supplied with a hash" do
        should "return a year representing the hash" do
          year = @question.parse_input(year: 2015)
          assert_equal 2015, year
        end

        should "raise an InvalidResponse exception when the hash value cannot be parsed an an Integer" do
          assert_raises(InvalidResponse) do
            @question.parse_input(year: "abc")
          end
        end
      end

      context "when supplied with a string" do
        should "return a year representing the string" do
          year = @question.parse_input("2015")
          assert_equal 2015, year
        end

        should "raise an InvalidResponse exception when the string represents an invalid year" do
          assert_raises(InvalidResponse) do
            @question.parse_input("!")
          end
        end

        should "raise an InvalidResponse exception when the string is empty" do
          assert_raises(InvalidResponse) do
            @question.parse_input("")
          end
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

    test "years are parsed from Hash into Date before being saved" do
      q = Question::Year.new(nil, :example) do
        on_response do |response|
          self.date = response
        end

        next_node { outcome :done }
      end

      new_state = q.transition(@initial_state, year: 2015)
      assert_equal Date.parse("2015-01-01").year, new_state.date
    end

    test "invalid years raise an error" do
      q = Question::Year.new(nil, :example) do
        on_response do |response|
          self.date = response
        end

        next_node { outcome :done }
      end

      assert_raise SmartAnswer::InvalidResponse do
        q.transition(@initial_state, year: "!")
      end
    end

    test "rejects years before a specified from year" do
      question = Question::Year.new(nil, :example) do
        from { 2015 }
        next_node { outcome :done }
      end

      assert_raises(InvalidResponse) do
        question.transition(@initial_state, "2014")
      end
    end

    test "accepts years equal to the specified from date" do
      question = Question::Year.new(nil, :example) do
        from { 2015 }
        next_node { outcome :done }
      end

      new_state = question.transition(@initial_state, "2015")
      assert @initial_state != new_state
    end

    test "accepts year greater than the specified from date" do
      question = Question::Year.new(nil, :example) do
        from { 2015 }
        next_node { outcome :done }
      end

      new_state = question.transition(@initial_state, "2016")
      assert @initial_state != new_state
    end

    test "rejects years after a specified to date" do
      question = Question::Year.new(nil, :example) do
        to { 2015 }
        next_node { outcome :done }
      end

      assert_raises(InvalidResponse) do
        question.transition(@initial_state, "2016")
      end
    end

    test "accepts years equal to the specified to date" do
      question = Question::Year.new(nil, :example) do
        to { 2015 }
        next_node { outcome :done }
      end

      new_state = question.transition(@initial_state, "2015")
      assert @initial_state != new_state
    end

    test "accepts years less than the specified to date" do
      question = Question::Year.new(nil, :example) do
        to { 2015 }
        next_node { outcome :done }
      end

      new_state = question.transition(@initial_state, "2014")
      assert @initial_state != new_state
    end
  end
end
