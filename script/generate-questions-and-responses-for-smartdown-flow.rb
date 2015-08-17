unless flow_name = ARGV.shift
  puts "Usage: #{__FILE__} <flow-name>"
  exit 1
end

smart_answer_helper = SmartAnswerTestHelper.new(flow_name)

flow = SmartdownAdapter::Registry.instance.find(flow_name)
questions_and_responses = {}
unknown_questions = []

flow.question_pages.each do |question|
  question.questions.each do |question|
    if question.is_a?(Smartdown::Api::MultipleChoice)
      questions_and_responses[question.name] = question.options.map(&:value)
    else
      warn "Don't know how to handle questions of type: #{question.class} (Question: #{question.name})"

      questions_and_responses[question.name] = [
        "TODO: #{question.title}"
      ]
      unknown_questions << [question.name, question.title]
    end
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
