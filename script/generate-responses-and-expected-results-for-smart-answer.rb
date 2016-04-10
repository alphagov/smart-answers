require 'timecop'

Timecop.freeze(Date.parse('2015-01-01'))

unless flow_name = ARGV.shift
  puts "Usage: #{__FILE__} <flow-name>"
  exit 1
end

if ENV["TEST_COVERAGE"]
  require 'simplecov'
  require 'simplecov-rcov'

  SimpleCov.command_name "Generate Responses & Expected Results"
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start 'rails'
end

smart_answer_helper = SmartAnswerTestHelper.new(flow_name)

questions_and_responses_path = smart_answer_helper.question_and_responses_path
unless File.exist?(questions_and_responses_path)
  puts "Questions and responses file doesn't exist."
  puts "Generate it using the generate-responses-for-smart-answer script."
  exit 1
end

questions_and_responses_yaml = File.read(questions_and_responses_path)
QUESTIONS_AND_RESPONSES = YAML.load(questions_and_responses_yaml)

flow = SmartAnswer::FlowRegistry.instance.find(flow_name)
RESPONSES_AND_EXPECTED_RESULTS = []

def answer_question(flow, state)
  question_name      = state.current_node
  existing_responses = state.responses

  QUESTIONS_AND_RESPONSES[question_name].each do |response|
    responses = existing_responses + [response]
    state     = flow.process(responses)
    next_node = flow.node(state.current_node)

    RESPONSES_AND_EXPECTED_RESULTS << {
      current_node: question_name,
      responses: responses.map(&:to_s),
      next_node: next_node.name,
      outcome_node: next_node.outcome?
    }

    unless next_node.outcome? || state.error
      answer_question(flow, state)
    end
  end
end

state = flow.start_state
answer_question(flow, state)

smart_answer_helper.write_responses_and_expected_results(RESPONSES_AND_EXPECTED_RESULTS)
puts "Responses and expected results written to #{smart_answer_helper.responses_and_expected_results_path}"
