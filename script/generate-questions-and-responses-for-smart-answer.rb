unless flow_name = ARGV.shift
  puts "Usage: #{__FILE__} <flow-name>"
  exit 1
end

smart_answer_helper = SmartAnswerTestHelper.new(flow_name)

flow = SmartAnswer::FlowRegistry.instance.find(flow_name)
questions_and_responses = {}
unknown_questions = []

module MethodMissingHelper
  def method_missing(method, *args, &block)
    MethodMissingObject.new(method)
  end
end

flow.questions.each do |question|
  if question.is_a?(SmartAnswer::Question::CountrySelect)
    questions_and_responses[question.name] = question.options.map(&:slug)
  elsif question.respond_to?(:options)
    questions_and_responses[question.name] = question.options
  else
    # Find the question text so that we can write it to the YAML file
    question_node = flow.node(question)
    i18n_prefix = ['flow', flow_name].join('.')
    begin
      question_text = QuestionPresenter.new(i18n_prefix, question_node, {}, helpers: [MethodMissingHelper]).title
    rescue I18n::MissingInterpolationArgument => e
      question_text = e.string
    end

    questions_and_responses[question.name] = [
      "TODO: #{question_text}"
    ]
    unknown_questions << [question.name, question_text]
  end
end

smart_answer_helper.write_questions_and_responses(questions_and_responses)

puts "Questions and responses written to: #{smart_answer_helper.question_and_responses_path}"
if unknown_questions.any?
  puts "You'll need to manually add responses for:"
  unknown_questions.each do |(question_name, question_text)|
    puts "* #{question_text} (#{question_name})"
  end
end
