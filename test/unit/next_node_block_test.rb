require_relative '../test_helper'

module SmartAnswer
  module Question
    class ParserTest < ActiveSupport::TestCase
      setup do
        @parser = NextNodeBlock::Parser.new
      end

      should 'identify possible next nodes' do
        next_node_block = -> do
          question :question_one
          outcome :outcome_one
        end

        possible_next_nodes = @parser.possible_next_nodes(next_node_block)

        assert_equal [:question_one, :outcome_one], possible_next_nodes
      end

      should 'ignore invocations with too few arguments' do
        next_node_block = -> do
          question
          outcome
        end

        possible_next_nodes = @parser.possible_next_nodes(next_node_block)

        assert possible_next_nodes.empty?
      end

      should 'ignore invocations with too many arguments' do
        next_node_block = -> do
          question :question_one, :unexpected_arg
          outcome :outcome_one, :unexpected_arg
        end

        possible_next_nodes = @parser.possible_next_nodes(next_node_block)

        assert possible_next_nodes.empty?
      end

      should 'ignore invocations with non-symbol argument' do
        next_node_block = -> do
          question 'question_one'
          outcome 'outcome_one'
        end

        possible_next_nodes = @parser.possible_next_nodes(next_node_block)

        assert possible_next_nodes.empty?
      end
    end
  end
end
