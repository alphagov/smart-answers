require_relative '../test_helper'

module SmartAnswer
  module Question
    class PermittedNodeKeyTest < ActiveSupport::TestCase
      context 'key constructed with nil' do
        setup do
          @key = NextNodeBlock::PermittedNodeKey.new(nil)
        end

        should 'be nil' do
          assert @key.nil?
        end

        should 'be blank' do
          assert @key.blank?
        end

        should 'not be present' do
          refute @key.present?
        end
      end

      context 'key constructed with symbol' do
        setup do
          @key = NextNodeBlock::PermittedNodeKey.new(:key)
        end

        should 'be nil' do
          refute @key.nil?
        end

        should 'not be blank' do
          refute @key.blank?
        end

        should 'be present' do
          assert @key.present?
        end

        should 'delegate to_sym to underlying object' do
          assert_equal :key, @key.to_sym
        end

        should 'delegate to_s to underlying object' do
          assert_equal 'key', @key.to_s
        end
      end
    end

    class NextNodeBlockTest < ActiveSupport::TestCase
      include NextNodeBlock::InstanceMethods

      should 'permit node key specified via question method' do
        assert NextNodeBlock.permitted?(question(:key))
      end

      should 'permit node key specified via outcome method' do
        assert NextNodeBlock.permitted?(outcome(:key))
      end

      should 'not permit node key not specified via syntactic sugar method' do
        refute NextNodeBlock.permitted?(:key)
      end

      should 'not permit nil node key' do
        refute NextNodeBlock.permitted?(nil)
      end
    end

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
