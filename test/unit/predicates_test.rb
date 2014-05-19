# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  module Predicate
    class PredicatesTest < ActiveSupport::TestCase
      setup do
        @state = State.new("start")
      end

      test "Callable predicate evaluates its callable in the context of the given state" do
        @state.calls_received = []
        predicate = Callable.new(->(response) { calls_received << response; calls_received.size == 1 })
        assert predicate.call(@state, 'response1')
        refute predicate.call(@state, 'response2')
        assert_equal ['response1', 'response2'], @state.calls_received
      end

      context "RespondedWith predicate" do
        setup do
          @predicate = RespondedWith.new(%w{a b c})
        end

        should "check whether the response was one of the permitted options" do
          assert @predicate.call(@state, 'a')
          refute @predicate.call(@state, 'd')
        end

        should "make label from the alternation of options" do
          assert_equal "a | b | c", @predicate.label
        end
      end

      context "ResponseHasAllOf predicate" do
        should "return true if all responses met" do
          predicate = ResponseHasAllOf.new(%w{red green})
          refute predicate.call(@state, '')
          refute predicate.call(@state, 'red')
          refute predicate.call(@state, 'blue')
          refute predicate.call(@state, 'green')
          refute predicate.call(@state, 'red,blue')
          assert predicate.call(@state, 'red,green')
          refute predicate.call(@state, 'blue,green')
          assert predicate.call(@state, 'red,blue,green')
        end

        should "always be true if empty requirements" do
          predicate = ResponseHasAllOf.new([])
          assert predicate.call(@state, '')
          assert predicate.call(@state, 'red')
        end

        should "make label from options" do
          predicate = ResponseHasAllOf.new(%w{red green})
          assert_equal "red & green", predicate.label
        end
      end

      context "ResponseIsOneOf predicate" do
        setup do
          @predicate = ResponseIsOneOf.new(%w{a b c})
        end

        should "splits the response on comma and indicates if any of the options present" do
          assert @predicate.call(@state, 'a,b,c')
          assert @predicate.call(@state, 'a,c,d')
          assert @predicate.call(@state, 'a')
          refute @predicate.call(@state, 'd,e,f')
        end

        should "make label from options" do
          assert_equal "a | b | c", @predicate.label
        end
      end

      context "VariableMatches predicate" do
        setup do
          @predicate = VariableMatches.new(:my_var, %w{a b})
        end

        should "tests if the named variable matches any of the values" do
          @state.my_var = 'a'
          assert @predicate.call(@state, '')
          @state.my_var = 'c'
          refute @predicate.call(@state, '')
        end

        should "make label from options" do
          assert_equal "my_var == { a | b }", @predicate.label
        end
      end
    end
  end
end
