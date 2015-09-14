# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class CheckboxQuestionTest < ActiveSupport::TestCase
    context "specifying options" do
      should "be able to specify options, and retreive them in the order specified" do
        q = Question::Checkbox.new(nil, :something) do
          option :red
          option 'blue'
          option :green
          option 'blue-green'
          option :reddy_brown
        end

        assert_equal ["red", "blue", "green", "blue-green", "reddy_brown"], q.options
      end

      should "not be able to use reserved 'none' option" do
        assert_raise InvalidNode do
          q = Question::Checkbox.new(nil, :something) { option :none }
        end
      end

      should "not be able to use options with non URL safe characters" do
        assert_raise InvalidNode do
          q = Question::Checkbox.new(nil, :something) { option 'a space' }
        end
        assert_raise InvalidNode do
          q = Question::Checkbox.new(nil, :something) { option 'a,comma' }
        end
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
          assert_equal 'green,red', @question.parse_input(['red', 'green'])
        end

        should "raise an error if given a non-existing response" do
          assert_raise InvalidResponse do
            @question.parse_input ['blue', 'orange']
          end
        end
      end

      context "with a comma separated string" do
        should "return the responses as a sorted comma-separated string" do
          assert_equal 'green,red', @question.parse_input('red,green')
        end

        should "raise an error if given a non-existing response" do
          assert_raise InvalidResponse do
            @question.parse_input 'blue,orange'
          end
        end
      end

      context "handling the special none case" do
        should "return none when passed nil" do
          assert_equal 'none', @question.parse_input(nil)
        end

        should "return none when passed special value 'none'" do
          assert_equal 'none', @question.parse_input('none')
        end
      end
    end

    context "converting to a response" do
      setup do
        @question = Question::Checkbox.new(nil, :something) do
          option :red
          option :blue
          option :green
        end
      end

      should "return an array of responses" do
        assert_equal ['red', 'green'], @question.to_response('red,green')
      end

      should "remove the none option from the results" do
        assert_equal [], @question.to_response('none')
      end
    end

    context "predicate helper functions" do
      setup do
        @question = Question::Checkbox.new(nil, :something)
      end

      should "define response_has_all_of" do
        assert @question.response_has_all_of([]).is_a?(SmartAnswer::Predicate::ResponseHasAllOf)
      end

      should "define response_is_one_of" do
        assert @question.response_is_one_of([]).is_a?(SmartAnswer::Predicate::ResponseIsOneOf)
      end
    end
  end
end
