module ExperimentalFlowTestHelper
  def self.included(object)
    object.extend(ClassMethods)
  end

  def testing_flow(flow_class)
    @test_flow = TestFlow.new(flow_class)
  end

  def testing_node(node_name)
    @test_flow.testing_node = node_name
  end

  def subject
    @test_flow
  end

  def add_responses(responses)
    @test_flow.add_responses(responses)
  end

  def add_response(response)
    @test_flow.add_response(response)
  end

  def assert_next_node(next_node)
    assert_nil @test_flow.state.error
    assert_equal next_node, @test_flow.current_node_name

    case @test_flow.current_node_type
    when :question
      assert_not_empty @test_flow.question_title
    when :outcome
      assert_not_empty @test_flow.outcome_body
    else
      raise "Unknown node type for #{next_node}"
    end
  end

  def assert_invalid_response(response)
    ensure_valid_and_correct_node
    add_response(response)

    assert_not_nil @test_flow.state.error,
                   "Expected #{response} to produce an error, instead current node is #{@test_flow.current_node_name}"
  end

  def assert_valid_response(response)
    ensure_valid_and_correct_node
    add_response(response)

    assert_nil @test_flow.state.error,
               "Expected #{response} to be valid, instead it produced error #{@test_flow.state.error}"
  end

  def ensure_valid_and_correct_node
    if @test_flow.state.error
      raise "Error in responses. Node #{@test_flow.current_node_name} has an error of: #{@test_flow.state.error}"
    end

    unless @test_flow.testing_node == @test_flow.current_node_name
      raise "Error in responses. Current node is #{@test_flow.current_node_name} and not the expected #{@test_flow.testing_node}"
    end
  end

  def assert_rendered_outcome(text: nil)
    ensure_valid_and_correct_node

    assert_not_empty @test_flow.outcome_body
    assert_match text, @test_flow.outcome_body_text if text
  end

  def assert_rendered_question
    ensure_valid_and_correct_node

    assert_not_empty @test_flow.question_title
  end

  class TestFlow
    attr_reader :flow

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

      responses.each do |key, value|
        raise "Invalid question #{key}" unless question_names.include?(key.to_sym)

        unless value.is_a?(String) || (value.is_a?(Array) && value.all? { |v| v.is_a?(String) })
          raise "response values must be a string or an array of strings"
        end

        @response_store.add(key.to_s, value)
      end
    end

    def add_response(response)
      add_responses({ state.current_node => response })
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

    def current_node_name
      state.current_node
    end

    def current_node_type
      if flow.questions.any? { |q| q.name == state.current_node }
        :question
      elsif flow.outcomes.any? { |o| o.name == state.current_node }
        :outcome
      end
    end

    def question_title
      raise "#{state.current_node} is not a question" unless current_node_type == :question

      QuestionPresenter.new(flow.node(state.current_node), nil, state).title
    end

    def outcome_body
      raise "#{state.current_node} is not an outcome" unless current_node_type == :outcome

      OutcomePresenter.new(flow.node(state.current_node), nil, state).body
    end

    def outcome_body_text
      Nokogiri::HTML::DocumentFragment.parse(outcome_body).text
    end
  end

  module ClassMethods
    def render_start_page
      RenderStartPageMatcher.new
    end

    def render_question
      RenderQuestionMatcher.new
    end

    def have_next_node(next_node)
      NextNodeMatcher.new(next_node)
    end
  end

  class RenderStartPageMatcher
    def description
      "render a start page"
    end

    def matches?(test_flow)
      start_node_presenter = StartNodePresenter.new(test_flow.flow.start_node)
      @issues = []
      @issues << "Missing title" if start_node_presenter.title.blank?
      @issues << "Missing body" if start_node_presenter.body.blank?
      @issues.empty?
    end

    def failure_message
      "Start page didn't render correctly: #{@issues.join(', ')}"
    end
  end

  class RenderQuestionMatcher
    def in_context(context)
      @context = context
    end

    def description
      "render question"
    end

    def matches?(_test_flow)
      @context.public_send(:assert_rendered_question)
    end
  end

  class NextNodeMatcher
    def initialize(next_node)
      @next_node = next_node
    end

    def in_context(context)
      @context = context
    end

    def description
      "have next node #{@next_node} for response #{@response}"
    end

    def for_response(response)
      @response = response
      self
    end

    def matches?(test_flow)
      test_flow.add_response(@response) if @response
      @context.public_send(:assert_next_node, @next_node)
    end
  end
end
