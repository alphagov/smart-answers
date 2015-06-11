module FlowTestHelper
  def setup_for_testing_flow(flow_slug_or_class)
    if flow_slug_or_class.is_a?(String)
      @flow = SmartAnswer::FlowRegistry.instance.find(flow_slug_or_class)
    else
      @flow = flow_slug_or_class.build
    end
    @responses = []
  end

  def add_response(resp)
    @responses << resp.to_s
  end

  def current_state
    if @cached_responses && @cached_responses != @responses
      @cached_responses, @state = nil, nil
    end
    @state ||= begin
      @cached_responses = @responses.dup
      @flow.process(@responses)
    end
  end

  def outcome_body
    @outcome_body ||= begin
      presenter = OutcomePresenter.new("flow.#{@flow.name}", @flow.node(current_state.current_node), current_state)
      Nokogiri::HTML::DocumentFragment.parse(presenter.body)
    end
  end

  def assert_current_node(node_name, opts = {})
    assert_equal node_name, current_state.current_node
    assert @flow.node_exists?(node_name), "Node #{node_name} does not exist."
    opts[:error] ? assert_current_node_is_error : assert_not_error
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

  def assert_phrase_list(variable_name, expected_keys)
    phrase_list = current_state.send(variable_name)
    assert phrase_list.is_a?(SmartAnswer::PhraseList), "State variable #{variable_name} is not a PhraseList"

    missing_keys = expected_keys - phrase_list.phrase_keys
    unexpected_keys = phrase_list.phrase_keys - expected_keys
    message = ""
    message += "Missing keys: #{missing_keys}\n" if missing_keys.present?
    message += "Unexpected keys: #{unexpected_keys}" if unexpected_keys.present?
    assert_equal expected_keys, phrase_list.phrase_keys, message
  end

  def assert_phrase_blank(variable_name)
    phrase_list = current_state.send(variable_name)
    assert phrase_list == nil, "State variable #{variable_name} was not expected to be in the PhraseList"
  end

  def assert_phrase_lists_include(expected_key)
    phrase_lits = current_state.to_h.select { |key, value| value.is_a?(::SmartAnswer::PhraseList) }
    all_keys = phrase_lits.values.flat_map(&:phrase_keys).map(&:to_sym)
    message = "Expected any phrase list to include '#{expected_key}', but it's not\n"
    phrase_lits.each do |name, list|
      message += "#{name}: #{list.phrase_keys}\n"
    end
    assert all_keys.include?(expected_key.to_sym), message
  end
end
