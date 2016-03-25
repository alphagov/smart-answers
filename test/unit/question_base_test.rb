require_relative '../test_helper'

class QuestionBaseTest < ActiveSupport::TestCase
  setup do
    @question = SmartAnswer::Question::Base.new(nil, :example_question)
  end

  context '#next_node' do
    should 'raise exception if next_node is called without a block' do
      e = assert_raises(ArgumentError) do
        @question.next_node
      end
      assert_equal 'You must specify a block', e.message
    end

    should 'raise exception if next_node is invoked multiple times' do
      e = assert_raises do
        @question.next_node { outcome :one }
        @question.next_node { outcome :two }
      end
      assert_equal 'Multiple calls to next_node are not allowed', e.message
    end
  end

  context '#permitted_next_nodes' do
    should 'return nodes returned via syntactic sugar methods' do
      @question.next_node do |response|
        if response == 'yes'
          outcome :done
        else
          question :another_question
        end
      end
      assert_equal [:done, :another_question], @question.permitted_next_nodes
    end

    should 'not return nodes not returned via syntactic sugar methods' do
      @question.next_node do |response|
        if response == 'yes'
          outcome :done
        else
          :another_question
        end
      end
      assert @question.permitted_next_nodes.include?(:done)
      refute @question.permitted_next_nodes.include?(:another_question)
    end

    should 'not return duplicate permitted next nodes' do
      @question.next_node do |response|
        if response == 'yes'
          outcome :done
        else
          outcome :done
        end
      end
      assert_equal [:done], @question.permitted_next_nodes
    end
  end

  context '#transition' do
    should "copy values from initial state to new state" do
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      initial_state.something_else = "Carried over"
      new_state = @question.transition(initial_state, :yes)
      assert_equal "Carried over", new_state.something_else
    end

    should "set current_node to value returned from next_node_for" do
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      @question.stubs(:next_node_for).returns(:done)
      new_state = @question.transition(initial_state, :anything)
      assert_equal :done, new_state.current_node
    end

    should "set current_node to result of calling next_node block" do
      @question.next_node { outcome :done_done }
      initial_state = SmartAnswer::State.new(@question.name)
      new_state = @question.transition(initial_state, :anything)
      assert_equal :done_done, new_state.current_node
    end

    should "make state available to code in next_node block" do
      @question.next_node do
        colour == 'red' ? outcome(:was_red) : outcome(:wasnt_red)
      end
      initial_state = SmartAnswer::State.new(@question.name)
      initial_state.colour = 'red'
      new_state = @question.transition(initial_state, 'anything')
      assert_equal :was_red, new_state.current_node
    end

    should "ensure state made available to code in next_node block is frozen" do
      state_made_available = nil
      @question.next_node do
        state_made_available = self
        outcome :done
      end
      initial_state = SmartAnswer::State.new(@question.name)
      @question.transition(initial_state, 'anything')
      assert state_made_available.frozen?
    end

    should "pass input to next_node block" do
      input_was = nil
      @question.next_node do |input|
        input_was = input
        outcome :done
      end
      initial_state = SmartAnswer::State.new(@question.name)
      @question.transition(initial_state, 'something')
      assert_equal 'something', input_was
    end

    should "make save_input_as method available to code in next_node block" do
      @question.save_input_as :colour_preference
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      new_state = @question.transition(initial_state, :red)
      assert_equal :red, new_state.colour_preference
    end

    should "save input sequence on new state" do
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      new_state = @question.transition(initial_state, :red)
      assert_equal [:red], new_state.responses
    end

    should "save path on new state" do
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      new_state = @question.transition(initial_state, :red)
      assert_equal [@question.name], new_state.path
    end

    should "execute on_response block with response" do
      @question.on_response do |response|
        self.my_responses << response
      end
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      initial_state.my_responses = []
      new_state = @question.transition(initial_state, :red)
      assert_equal [:red], new_state.my_responses
    end

    should "execute on_response block before next_node_calculation" do
      @question.on_response do
        self.foo = :value_from_on_response_block
      end
      @question.next_node_calculation(:bar) do
        foo
      end
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      new_state = @question.transition(initial_state, :red)
      assert_equal :value_from_on_response_block, new_state.bar
    end

    should "execute on_response block before validation" do
      @question.on_response do
        self.foo = :value_from_on_response_block
      end
      @question.validate do
        foo != :value_from_on_response_block
      end
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      assert_raises(SmartAnswer::InvalidResponse) do
        @question.transition(initial_state, :red)
      end
    end

    should "execute calculate block with response and save result on new state" do
      @question.calculate :complementary_colour do |response|
        response == :red ? :green : :red
      end
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      new_state = @question.transition(initial_state, :red)
      assert_equal :green, new_state.complementary_colour
      assert new_state.frozen?
    end

    should "execute calculate block with saved input and save result on new state" do
      @question.save_input_as :colour_preference
      @question.calculate :complementary_colour do
        colour_preference == :red ? :green : :red
      end
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      new_state = @question.transition(initial_state, :red)
      assert_equal :green, new_state.complementary_colour
      assert new_state.frozen?
    end

    should "execute next_node_calculation block before next_node" do
      @question.next_node_calculation :complementary_colour do |response|
        response == :red ? :green : :red
      end
      @question.next_node_calculation :blah do
        "blah"
      end
      @question.next_node do
        outcome :done if complementary_colour == :green
      end
      initial_state = SmartAnswer::State.new(@question.name)
      new_state = @question.transition(initial_state, :red)
      assert_equal :green, new_state.complementary_colour
      assert_equal "blah", new_state.blah
      assert_equal :done, new_state.current_node
    end
  end

  context '#next_node_for' do
    should "raise an exception if next_node does not return key via question or outcome method" do
      @question.next_node do
        outcome :another_outcome
        :not_allowed_next_node
      end
      state = SmartAnswer::State.new(@question.name)

      expected_message = "Next node (not_allowed_next_node) not returned via question or outcome method"
      exception = assert_raises do
        @question.next_node_for(state, 'response')
      end
      assert_equal expected_message, exception.message
    end

    should "raise an exception if next_node does not return a node key" do
      responses = [:blue, :red]
      @question.next_node do
        skip = false
        outcome :skipped if skip
      end
      initial_state = SmartAnswer::State.new(@question.name)
      initial_state.responses << responses[0]
      error = assert_raises(SmartAnswer::Question::Base::NextNodeUndefined) do
        @question.next_node_for(initial_state, responses[1])
      end
      expected_message = "Next node undefined. Node: #{@question.name}. Responses: #{responses}."
      assert_equal expected_message, error.message
    end

    should "raise an exception if next_node was not called for question" do
      initial_state = SmartAnswer::State.new(@question.name)
      assert_raises(SmartAnswer::Question::Base::NextNodeUndefined) do
        @question.next_node_for(initial_state, :response)
      end
    end

    should "allow calls to #question syntactic sugar method" do
      @question.next_node { question :another_question }
      state = SmartAnswer::State.new(@question.name)
      next_node = @question.next_node_for(state, 'response')
      assert_equal :another_question, next_node
    end

    should "should allow calls to #outcome syntactic sugar method" do
      @question.next_node { outcome :done }
      state = SmartAnswer::State.new(@question.name)
      next_node = @question.next_node_for(state, 'response')
      assert_equal :done, next_node
    end
  end
end
