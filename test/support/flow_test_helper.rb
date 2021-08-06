module FlowTestHelper
  delegate :add_responses, :add_response, to: :test_flow

  def testing_flow(flow_class)
    @test_flow = TestFlow.new(flow_class)
  end

  def test_flow
    @test_flow || raise("Flow being tested has not been set, you should set testing_flow")
  end

  def testing_node(node_name)
    test_flow.testing_node = node_name
  end

  def assert_next_node(next_node, for_response: nil)
    add_response for_response if for_response

    assert_nil test_flow.state.error
    assert_equal next_node, test_flow.current_node_name

    case test_flow.current_node_type
    when :question
      assert_not_empty test_flow.question_title
    when :outcome
      assert_not_empty test_flow.outcome_text
    else
      raise "Unknown node type for #{next_node}"
    end
  end

  def assert_invalid_response(response)
    ensure_valid_and_correct_node
    add_response(response)

    assert_not_nil test_flow.state.error,
                   "Expected #{response} to produce an error, instead current node is #{test_flow.current_node_name}"
  end

  def assert_valid_response(response)
    ensure_valid_and_correct_node
    add_response(response)

    assert_nil test_flow.state.error,
               "Expected #{response} to be valid, instead it produced error #{test_flow.state.error}"
  end

  def ensure_valid_and_correct_node
    if test_flow.state.error
      raise "Error in responses. Node #{test_flow.current_node_name} has an error of: #{test_flow.state.error}"
    end

    unless test_flow.testing_node == test_flow.current_node_name
      raise "Error in responses. Current node is #{test_flow.current_node_name} and not the expected #{test_flow.testing_node}"
    end
  end

  def assert_rendered_start_page
    start_node_presenter = StartNodePresenter.new(test_flow.flow.start_node, nil, test_flow.state)

    assert_not_empty start_node_presenter.title, "Expected the start page to have a title"
    assert_not_empty start_node_presenter.body, "Expected the start page to have a body"
  end

  def assert_rendered_question
    ensure_valid_and_correct_node

    assert_not_empty test_flow.question_title
  end

  def assert_rendered_outcome(text: nil)
    ensure_valid_and_correct_node

    assert_not_empty test_flow.outcome_text
    assert_match text, test_flow.outcome_text if text
  end

  class TestFlow
    attr_reader :flow

    delegate :current_node_name, to: :state

    def initialize(flow_class)
      @flow = flow_class.build
      @response_store = ResponseStore.new(responses: {})
    end

    def testing_node=(node_name)
      node_names = flow.nodes.map(&:name)
      raise "Invalid node" unless node_names.include?(node_name)

      @testing_node = node_name
    end

    def testing_node
      @testing_node || raise("Node being tested has not been set, you should set testing_node")
    end

    def add_responses(responses)
      question_names = flow.questions.map(&:name)
      valid_parameters = question_names + flow.additional_parameters

      responses.each do |key, value|
        raise "Invalid question or query parameter: #{key}" unless valid_parameters.include?(key.to_sym)

        unless value.is_a?(String) || (value.is_a?(Array) && value.all? { |v| v.is_a?(String) })
          raise "response values must be a string or an array of strings"
        end

        @response_store.add(key.to_s, value)
      end
    end

    def add_response(response)
      add_responses({ state.current_node_name => response })
    end

    def state
      @cached_responses ||= nil
      if @cached_responses && @cached_responses != @response_store.all
        @cached_responses = nil
        @state = nil
      end

      @state ||= begin
        @cached_responses = @response_store.all.dup
        SmartAnswer::StateResolver.new(flow).state_from_response_store(@response_store)
      end
    end

    def current_node_is_testing_node?
      testing_node == current_node_name
    end

    def current_node_type
      if flow.questions.any? { |q| q.name == state.current_node_name }
        :question
      elsif flow.outcomes.any? { |o| o.name == state.current_node_name }
        :outcome
      end
    end

    def question_title
      raise "#{state.current_node_name} is not a question" unless current_node_type == :question

      QuestionPresenter.new(flow.node(state.current_node_name), nil, state).title
    end

    def outcome_body
      outcome_presenter.body
    end

    def outcome_title
      outcome_presenter.title
    end

    def outcome_body_text
      Nokogiri::HTML::DocumentFragment.parse(outcome_body).text
    end

    def outcome_text
      [outcome_title, outcome_body_text].reject(&:blank?).join("\n")
    end

    def outcome_presenter
      raise "#{state.current_node_name} is not an outcome" unless current_node_type == :outcome

      OutcomePresenter.new(flow.node(state.current_node_name), nil, state)
    end
  end
end
