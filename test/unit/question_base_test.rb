require_relative "../test_helper"

class QuestionBaseTest < ActiveSupport::TestCase
  setup do
    @question = SmartAnswer::Question::Base.new(nil, :example_question)
  end

  context "#on_response" do
    should "not allow multiple definitions of on_response" do
      assert_raises(RuntimeError, "Multiple on_response blocks not allowed") do
        @question.on_response { |_| nil }
        @question.on_response { |_| nil }
      end
    end
  end

  context "#transition" do
    should "pass input to next_node block" do
      input_was = nil
      @question.next_node do |input|
        input_was = input
        outcome :done
      end
      initial_state = SmartAnswer::State.new(@question.name)
      @question.transition(initial_state, "something")
      assert_equal "something", input_was
    end

    should "execute on_response block with response" do
      @question.on_response do |response|
        my_responses << response
      end
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      initial_state.my_responses = []
      new_state = @question.transition(initial_state, :red)
      assert_equal [:red], new_state.my_responses
    end

    should "execute on_response block before validate" do
      @question.on_response do
        self.foo = :value_from_on_response_block
      end
      @question.validate do
        foo == :value_from_on_response_block
      end
      @question.next_node { outcome :done }
      initial_state = SmartAnswer::State.new(@question.name)
      new_state = @question.transition(initial_state, :red)
      assert_equal :value_from_on_response_block, new_state.foo
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
  end
end
