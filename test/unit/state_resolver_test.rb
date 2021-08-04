require_relative "../test_helper"

module SmartAnswer
  class StateResolverTest < ActiveSupport::TestCase
    setup do
      @flow = SmartAnswer::Flow.build do
        additional_parameters %w[c d]

        setup do
          self.e = :f
        end

        radio :x do
          option :yes
          option :no
          next_node do |response|
            case response
            when "yes" then outcome :y
            when "no" then question :a
            end
          end
        end

        radio :y do
          option :yes
          option :no
          next_node do |response|
            case response
            when "yes" then outcome :a
            when "no" then outcome :b
            end
          end
        end
        outcome :a
        outcome :b
      end

      @state_resolver = StateResolver.new(@flow)
    end

    context "#state_from_response_store" do
      should "return the state for the first question when there are no responses" do
        response_store = ResponseStore.new(responses: {})
        state = @state_resolver.state_from_response_store(response_store)

        assert_equal :x, state.current_node_name
        assert_empty state.accepted_responses
        assert_nil state.current_response
      end

      should "return the state for the next question when there are valid answers" do
        response_store = ResponseStore.new(responses: { "x" => "yes" })
        state = @state_resolver.state_from_response_store(response_store)

        assert_equal :y, state.current_node_name
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_nil state.current_response
      end

      should "return an outcome state when all questions are answered" do
        response_store = ResponseStore.new(responses: { "x" => "yes", "y" => "no" })
        state = @state_resolver.state_from_response_store(response_store)

        assert_equal :b, state.current_node_name
        assert_equal ({ x: "yes", y: "no" }), state.accepted_responses
        assert_nil state.current_response
      end

      should "return an error state for the current question when an answer is invalid" do
        response_store = ResponseStore.new(responses: { "x" => "yes", "y" => "invalid" })
        state = @state_resolver.state_from_response_store(response_store)

        assert_equal :y, state.current_node_name
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_equal "invalid", state.current_response
        assert state.error.present?
      end

      should "return an error state for an earlier node regardless of a requested node" do
        response_store = ResponseStore.new(responses: { "x" => "invalid", "y" => "no" })
        state = @state_resolver.state_from_response_store(response_store, "y")

        assert_equal :x, state.current_node_name
        assert_equal ({}), state.accepted_responses
        assert_equal "invalid", state.current_response
        assert state.error.present?
      end

      should "return an error state if there is an error on the requested node" do
        response_store = ResponseStore.new(responses: { "x" => "invalid", "y" => "no" })
        state = @state_resolver.state_from_response_store(response_store, "x")

        assert_equal :x, state.current_node_name
        assert_equal ({}), state.accepted_responses
        assert_equal "invalid", state.current_response
        assert state.error.present?
      end

      should "return a particular node if one is requested" do
        response_store = ResponseStore.new(responses: { "x" => "yes", "y" => "no" })
        state = @state_resolver.state_from_response_store(response_store, "y")

        assert_equal :y, state.current_node_name
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_equal "no", state.current_response
      end

      should "return an earlier node rather than the requested one if a response is missing" do
        response_store = ResponseStore.new(responses: { "y" => "no" })
        state = @state_resolver.state_from_response_store(response_store, "y")

        assert_equal :x, state.current_node_name
        assert_equal ({}), state.accepted_responses
        assert_nil state.current_response
      end

      should "set additional parameters on the state" do
        response_store = ResponseStore.new(responses: { "x" => "yes", "c" => "true" })
        state = @state_resolver.state_from_response_store(response_store)

        assert_equal :y, state.current_node_name
        assert_equal "true", state.c
      end

      should "run setup on the start state" do
        response_store = ResponseStore.new(responses: {})
        state = @state_resolver.state_from_response_store(response_store)

        assert_equal :f, state.e
      end
    end

    context "#state_from_params" do
      should "return the state for the first question when there are no responses" do
        state = @state_resolver.state_from_params({ responses: "" })

        assert_equal :x, state.current_node_name
        assert_empty state.accepted_responses
        assert_nil state.current_response
      end

      should "return the state for the next question when a valid answer is given" do
        state = @state_resolver.state_from_params({ responses: "", next: "1", response: "yes" })

        assert_equal :y, state.current_node_name
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_nil state.current_response
      end

      should "return the state for the next question when an answer is in the path" do
        state = @state_resolver.state_from_params({ responses: "yes" })

        assert_equal :y, state.current_node_name
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_nil state.current_response
      end

      should "return an error state for the current question when an answer is invalid" do
        state = @state_resolver.state_from_params({ responses: "yes/invalid" })

        assert_equal :y, state.current_node_name
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_equal "invalid", state.current_response
        assert state.error.present?
      end

      should "return an outcome state when all questions are answered" do
        state = @state_resolver.state_from_params({ responses: "yes/no" })

        assert_equal :b, state.current_node_name
        assert_equal ({ x: "yes", y: "no" }), state.accepted_responses
        assert_nil state.current_response
      end

      should "determine the current response from a previous_response parameter" do
        state = @state_resolver.state_from_params({ responses: "yes", previous_response: "no" })

        assert_equal :y, state.current_node_name
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_equal "no", state.current_response
      end

      should "return an error state if a previous_response contains an invalid response" do
        state = @state_resolver.state_from_params({ responses: "yes", previous_response: "invalid" })

        assert_equal :y, state.current_node_name
        assert_equal ({ x: "yes" }), state.accepted_responses
        assert_equal "invalid", state.current_response
      end
    end
  end
end
