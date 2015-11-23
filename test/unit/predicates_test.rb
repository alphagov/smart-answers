
require_relative '../test_helper'

module SmartAnswer
  module Predicate
    class PredicatesTest < ActiveSupport::TestCase
      setup do
        @state = State.new("start")
      end

      context "Base predicate" do
        should "take a label as its first argument" do
          example_label = "my label"
          assert_equal example_label, SmartAnswer::Predicate::Base.new(example_label).label
        end

        should "take a callable as its second argument" do
          @state.calls_received = []
          callable = ->(state, response) { state.calls_received << response }
          predicate = SmartAnswer::Predicate::Base.new(nil, callable)
          predicate.call(@state, "a")
          assert_equal ['a'], @state.calls_received
        end

        should "be able to create a logical union of two predicates with shortcut execution" do
          @state.p1_calls_received = []
          @state.p2_calls_received = []
          p1 = SmartAnswer::Predicate::Base.new('p1', ->(state, response) { state.p1_calls_received << response; response == 'a' })
          p2 = SmartAnswer::Predicate::Base.new('p2', ->(state, response) { state.p2_calls_received << response; response == 'b' })
          union = p1 | p2
          assert union.call(@state, 'a')
          assert_equal ['a'], @state.p1_calls_received
          assert_equal [], @state.p2_calls_received
          assert union.call(@state, 'b')
          assert_equal ['a', 'b'], @state.p1_calls_received
          assert_equal ['b'], @state.p2_calls_received
          refute union.call(@state, 'c')
          assert_equal ['a', 'b', 'c'], @state.p1_calls_received
          assert_equal ['b', 'c'], @state.p2_calls_received
        end

        should "combine using | operator" do
          p1 = SmartAnswer::Predicate::Base.new('p1')
          p2 = SmartAnswer::Predicate::Base.new('p2')
          assert_equal "p1 | p2", (p1 | p2).label
        end

        should "be able to override lable when combining using or()" do
          p1 = SmartAnswer::Predicate::Base.new('p1')
          p2 = SmartAnswer::Predicate::Base.new('p2')
          assert_equal "custom label", (p1.or(p2, "custom label")).label
        end

        should "be able to create a logical conjunction of two predicates with shortcut execution" do
          p_true = SmartAnswer::Predicate::Base.new('true', ->(_, _) { true })
          p_false = SmartAnswer::Predicate::Base.new('true', ->(_, _) { false })

          assert_equal true, (p_true & p_true).call(@state, 'any input')
          assert_equal false, (p_true & p_false).call(@state, 'any input')
          assert_equal false, (p_false & p_true).call(@state, 'any input')
          assert_equal false, (p_false & p_false).call(@state, 'any input')
        end

        should "predicate formed by logical conjunction has meaningful label" do
          p1 = SmartAnswer::Predicate::Base.new('p1', ->(_, _) { true })
          p2 = SmartAnswer::Predicate::Base.new('p2', ->(_, _) { true })

          assert_equal "p1 AND p2", (p1 & p2).label
        end

        should "be able to override lable when combining using and()" do
          p1 = SmartAnswer::Predicate::Base.new('p1')
          p2 = SmartAnswer::Predicate::Base.new('p2')
          assert_equal "custom label", (p1.and(p2, "custom label")).label
        end
      end

      context "Callable predicate" do
        should "take a label as its first argument" do
          example_label = "my label"
          assert_equal example_label, Callable.new(example_label).label
        end

        should "take a block" do
          call_count = 0
          predicate = Callable.new { call_count += 1 }
          predicate.call(@state, nil)
          assert_equal 1, call_count
        end

        context "take a lambda" do
          should "accept a lambda with arity of 1" do
            call_count = 0
            predicate = Callable.new("label", ->(_) { call_count += 1 })
            predicate.call(@state, nil)
            assert_equal 1, call_count
          end

          should "accept a lambda with arity of 0" do
            call_count = 0
            predicate = Callable.new("label", -> { call_count += 1 })
            predicate.call(@state, nil)
            assert_equal 1, call_count
          end
        end

        should "evaluate its callable in the context of the given state" do
          @state.calls_received = []
          predicate = Callable.new(nil, ->(response) { calls_received << response; calls_received.size == 1 })
          assert predicate.call(@state, 'response1')
          refute predicate.call(@state, 'response2')
          assert_equal ['response1', 'response2'], @state.calls_received
        end
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

        should "generate nice label when combining" do
          p1 = VariableMatches.new(:a, 1, "one")
          p2 = VariableMatches.new(:a, 2, "two")
          assert_equal "a == one | two", (p1 | p2).label
        end
      end
    end
  end
end
