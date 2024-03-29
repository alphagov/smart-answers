require_relative "../test_helper"

module SmartAnswer
  class CheckboxQuestionTest < ActiveSupport::TestCase
    context "specifying options" do
      should "be able to specify options, and retreive them in the order specified" do
        q = Question::Checkbox.new(nil, :something) do
          option :red
          option "blue"
          option :green
          option "blue-green"
          option :reddy_brown
        end

        assert_equal %w[red blue green blue-green reddy_brown], q.option_keys
      end

      should "be able to specify options with block" do
        q = Question::Checkbox.new(nil, :something) do
          options { %w[x y z] }
        end

        assert_equal %w[x y z], q.options_block.call
      end

      should "not be able to use reserved 'none' option" do
        assert_raise InvalidNode do
          Question::Checkbox.new(nil, :something) { option :none }
        end
      end

      should "not be able to use options with non URL safe characters" do
        assert_raise InvalidNode do
          Question::Checkbox.new(nil, :something) { option "a space" }
        end
        assert_raise InvalidNode do
          Question::Checkbox.new(nil, :something) { option "a,comma" }
        end
      end
    end

    context "setup" do
      should "resolve the options keys from the option block" do
        q = Question::Checkbox.new(nil, :example) do
          options { %i[x y] }
        end

        q.setup(nil)

        assert_equal %i[x y], q.option_keys
      end

      should "not clear options keys if option block is nil" do
        q = Question::Checkbox.new(nil, :example) do
          option :a
          option :b
        end

        q.setup(nil)

        assert_equal %w[a b], q.option_keys
      end
    end

    context "parsing response" do
      setup do
        @question = Question::Checkbox.new(nil, :something) do
          option :red
          option :blue
          option :green
        end
      end

      context "with an array" do
        should "return the responses as a sorted comma-separated string" do
          assert_equal "green,red", @question.parse_input(%w[red green])
        end

        should "raise an error if given a non-existing response" do
          assert_raise InvalidResponse do
            @question.parse_input %w[blue orange]
          end
        end
      end

      context "with a comma separated string" do
        should "return the responses as a sorted comma-separated string" do
          assert_equal "green,red", @question.parse_input("red,green")
        end

        should "raise an error if given a non-existing response" do
          assert_raise InvalidResponse do
            @question.parse_input "blue,orange"
          end
        end
      end

      context "handling the special none case" do
        should "return none when passed nil" do
          assert_equal "none", @question.parse_input(nil)
        end

        should "return none when passed special value 'none'" do
          assert_equal "none", @question.parse_input("none")
        end
      end

      context "with an explicitly set 'none' option" do
        setup do
          @question.none_option
        end

        should "enable the none option" do
          assert @question.none_option?
        end

        should "raise if the response is blank" do
          assert_raise InvalidResponse do
            @question.parse_input(nil)
          end
        end
      end
    end
  end
end
