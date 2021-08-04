module SmartAnswer
  class StateResolver
    def initialize(flow)
      @flow = flow
    end

    def state_from_response_store(response_store, requested_node = nil)
      start_state = State.new(@flow.questions.first.name)
      start_state.instance_eval(&@flow.setup) if @flow.setup

      @flow.additional_parameters.each do |param|
        start_state[param] = response_store.get(param)
      end

      resolve_state(start_state.freeze, response_store, requested_node)
    end

    def state_from_params(params)
      responses = params[:responses].to_s.split("/")
      start_state = State.new(@flow.questions.first.name).freeze

      state = responses.inject(start_state) do |current_state, response|
        return current_state if current_state.error

        transition_state_to_next_node(current_state, response)
      end

      if params[:next]
        transition_state_to_next_node(state, params[:response])
      elsif params[:previous_response]
        apply_response_to_state(state, params[:previous_response])
      else
        state
      end
    end

  private

    def resolve_state(state, response_store, requested_node)
      node_name = state.current_node_name.to_s
      response = response_store.get(node_name)
      reached_an_outcome = @flow.node(node_name.to_sym).outcome?

      return state if response.nil? || reached_an_outcome || state.error
      return apply_response_to_state(state, response) if requested_node == node_name

      next_state = transition_state_to_next_node(state, response)
      resolve_state(next_state, response_store, requested_node)
    end

    def apply_response_to_state(state, response)
      # test response for errors by transitioning to next node
      next_state = transition_state_to_next_node(state, response)
      return next_state if next_state.error

      # without errors, adapt current state to have response applied
      state.dup.tap do |current_state|
        current_state.current_response = response
        current_state.freeze
      end
    end

    def transition_state_to_next_node(state, response)
      @flow.node(state.current_node_name).transition(state, response)
    rescue BaseStateTransitionError => e
      error_state(state, response, e)
    end

    def error_state(state, response, error)
      GovukError.notify(error) if error.is_a?(LoggedError)

      state.dup.tap do |new_state|
        new_state.error = error.message
        new_state.current_response = response
        new_state.freeze
      end
    end
  end
end
