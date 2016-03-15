require_relative '../test_helper'

require 'ast/sexp'
require 'method_source'

module SmartAnswer
  class MethodInvocationsParserTest < ActiveSupport::TestCase
    include AST::Sexp

    context 'method with no arguments' do
      setup do
        mod = Module.new do
          def method_with_no_args; end
        end
        @method_with_no_args = mod.instance_method(:method_with_no_args)
        @parser = MethodInvocationsParser.new(@method_with_no_args)
      end

      should 'identify invocation of method with correct number of arguments' do
        block_invoking_method = -> do
          method_with_no_args
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert_equal 1, invocations.length
        assert_equal @method_with_no_args, invocations[0][:method]
        assert_equal [], invocations[0][:arg_nodes]
      end

      should 'identify multiple invocations of method' do
        block_invoking_method = -> do
          method_with_no_args
          method_with_no_args
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert_equal 2, invocations.length
      end

      should 'identify multiple invocations of method on one line' do
        block_invoking_method = -> do
          method_with_no_args; method_with_no_args
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert_equal 2, invocations.length
      end

      should 'identify invocations of method within conditional statement' do
        block_invoking_method = -> do
          condition = false
          if condition
            method_with_no_args
          end
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert_equal 1, invocations.length
      end

      should 'identify invocations of method within next statement' do
        block_invoking_method = -> do
          next method_with_no_args
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert_equal 1, invocations.length
      end

      should 'identify invocations of method within return statement' do
        block_invoking_method = -> do
          return method_with_no_args
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert_equal 1, invocations.length
      end

      should 'ignore invocation of method with too many arguments' do
        block_invoking_method = -> do
          method_with_no_args(:unexpected_arg)
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert invocations.empty?
      end

      should 'ignore invocation of method with wrong name' do
        block_invoking_method = -> do
          another_method_with_no_args
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert invocations.empty?
      end

      should 'ignore assignment to local variable with same name as method' do
        block_invoking_method = -> do
          another_method_with_no_args = 'ignore me'
          puts another_method_with_no_args
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert invocations.empty?
      end

      should 'ignore commented out method invocation' do
        block_invoking_method = -> do
          # method_with_no_args
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert invocations.empty?
      end
    end

    context 'method with two arguments' do
      setup do
        mod = Module.new do
          def method_with_two_args(arg_one, arg_two); end
        end
        @method_with_two_args = mod.instance_method(:method_with_two_args)
        @parser = MethodInvocationsParser.new(@method_with_two_args)
      end

      should 'identify invocation of method with correct number of arguments' do
        block_invoking_method = -> do
          method_with_two_args(:arg_one, :arg_two)
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert_equal 1, invocations.length
        assert_equal @method_with_two_args, invocations[0][:method]
        assert_equal [s(:sym, :arg_one), s(:sym, :arg_two)], invocations[0][:arg_nodes]
      end

      should 'ignore invocation of method with insufficient arguments' do
        block_invoking_method = -> do
          method_with_two_args(:only_one_arg)
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert invocations.empty?
      end
    end

    context 'method with optional arguments' do
      setup do
        mod = Module.new do
          def method_with_optional_arg(optional = :default); end
        end
        @method_with_optional_arg = mod.instance_method(:method_with_optional_arg)
        @parser = MethodInvocationsParser.new(@method_with_optional_arg)
      end

      should 'not identify invocation of method' do
        block_invoking_method = -> do
          method_with_optional_arg
          method_with_optional_arg(:non_default)
        end

        invocations = @parser.invocations(block_invoking_method.source)
        assert invocations.empty?
      end
    end
  end
end
