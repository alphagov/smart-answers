module FlowTestHelper
  def setup_for_testing_flow(klass)
    @flow = klass.build
    reset_responses
  end

  def reset_responses
    @responses = []
  end

  def add_response(resp)
    @responses << resp.to_s
  end

  def current_state
    @cached_responses ||= nil
    if @cached_responses && @cached_responses != @responses
      @cached_responses = nil
      @current_state = nil
    end
    @current_state ||= begin
      @cached_responses = @responses.dup
      @flow.process(@responses)
    end
  end

  def current_question
    @current_question ||= begin
      presenter = QuestionPresenter.new(@flow.node(current_state.current_node), nil, current_state)
      presenter.title
    end
  end

  def outcome_body
    @outcome_body ||= begin
      presenter = OutcomePresenter.new(@flow.node(current_state.current_node), nil, current_state)
      Nokogiri::HTML::DocumentFragment.parse(presenter.body)
    end
  end

  def assert_current_node(node_name, opts = {})
    assert_equal node_name, current_state.current_node
    assert @flow.node_exists?(node_name), "Node #{node_name} does not exist."
    if opts[:error]
      assert_current_node_is_error(opts[:error].is_a?(Class) ? (opts[:error]).to_s : nil)
    else
      assert_not_error
    end
  end

  # To be used with test class inheriting from ActionDispatch::IntegrationTest
  def assert_page_renders
    silence_warnings do # Without this get a Mocha deprecation warning that I was unable to find the source of.
      ContentItemRetriever.stubs(:fetch).returns({})
      path = "/#{@flow.name}/y/#{@responses.join('/')}"
      get path
      assert_equal response.code, "200"
    end
  end

  def assert_current_node_is_error(message = nil)
    assert current_state.error, "Expected #{current_state.current_node} to be in error state"
    assert_equal message, current_state.error if message
  end

  def assert_not_error
    assert current_state.error.nil?, "Unexpected Flow error: #{current_state.error}"
  end

  def assert_state_variable(name, expected, options = {})
    actual = current_state.send(name)
    if options[:round_dp]
      expected = sprintf("%.#{options[:round_dp]}f", expected)
      actual = sprintf("%.#{options[:round_dp]}f", actual)
    end
    assert_equal expected, actual
  end

  def assert_calculator_attr(name, expected)
    actual = current_state.calculator.send(name)
    assert_equal expected, actual
  end
end
