unless flow_name = ARGV.shift
  puts "Usage: #{__FILE__} <flow-name>"
  exit 1
end

registry = SmartdownAdapter::Registry.instance
coversheet_path = registry.send(:coversheet_path, flow_name)
input = Smartdown::Parser::DirectoryInput.new(coversheet_path)
flow = registry.find(flow_name)

smart_answer_root = SmartAnswer::FlowRegistry.instance.load_path
flow_path = smart_answer_root.join("#{flow_name}.rb")
locale_path = smart_answer_root.join('locales', 'en', "#{flow_name}.yml")

coversheet_title = flow.title.strip
coversheet_body = flow.coversheet.body.strip
coversheet_meta_description = flow.meta_description
start_node = flow.coversheet.elements.detect { |e| Smartdown::Model::Element::StartButton === e }.start_node

question_pages_vs_questions = flow.question_pages.inject({}) do |hash, question_page|
  if question_page.questions.length > 1
    raise "QuestionPage '#{question_page.name}' has multiple questions which is not yet supported by this conversion tool"
  end
  hash[question_page.name] = question_page.questions.first.name
  hash
end

questions = []
content_for_questions = Hash.new { |h, k| h[k] = {} }
flow.question_pages.each do |question_page|
  question = question_page.questions.first
  key = question.name
  content_for_questions[key]['title'] = question.title.strip
  content_for_questions[key]['body'] = question.body.strip if question.body.strip.present?
  content_for_questions[key]['post_body'] = question.post_body.strip if question.post_body.strip.present?

  next_node_rules = {}
  question_page.next_nodes.each do |next_node|
    if next_node.rules.all? { |r| (Smartdown::Model::Predicate::Equality === r.predicate) && r.predicate.varname == question.name }
      next_node_rules[:case_statement] = next_node.rules.inject({}) do |hash, rule|
        next_node = question_pages_vs_questions[rule.outcome] || rule.outcome
        hash[rule.predicate.expected_value] = next_node.to_sym; hash
      end
    else
      if flow_name == 'pay-leave-for-parents'
        next_node_rules[:comments] = ["Manually copy the rules from Smartdown"]
      else
        next_node_rules[:comments] = next_node.rules.inject([]) do |array, rule|
          next_node = question_pages_vs_questions[rule.outcome] || rule.outcome
          array << "#{rule.predicate.humanize} -> #{next_node}"; array
        end
      end
    end
  end

  q = { name: question.name.to_sym, next_node_rules: next_node_rules }
  case question
  when Smartdown::Api::MultipleChoice
    content_for_questions[key]['options'] = question.options.inject({}) { |h,o| h[o.value] = o.label; h }
    q[:type] = :multiple_choice
    q[:options] = question.options.map(&:value)
  when Smartdown::Api::PostcodeQuestion
    q[:type] = :postcode_question
    q[:options] = []
  when Smartdown::Api::DateQuestion
    q[:type] = :date_question
    q[:options] = []
  when Smartdown::Api::SalaryQuestion
    q[:type] = :salary_question
    q[:options] = []
  else
    raise "Question '#{question.name}' is of type '#{question.class}' which is not yet supported by this conversion tool"
  end

  if question_page.name == start_node
    questions.unshift(q)
  else
    questions.push(q)
  end
end

outcomes = flow.outcomes.inject([]) { |a,o| a << { name: o.name } }

flow_class = "#{flow_name.underscore.classify}Flow"
erb = File.read(Rails.root.join('script', 'templates', 'smart_answer_flow.erb'))
template = Erubis::Eruby.new(erb)
File.open(flow_path, 'w') do |file|
  file.write(template.result(binding))
end

i18n = {
  'en-GB' => {
    'flow' => {
      flow_name => content_for_questions
    }
  }
}

File.open(locale_path, 'w') do |file|
  file.write(i18n.to_yaml)
end

templates_root = smart_answer_root.join(flow_name)
FileUtils.remove_dir(templates_root, force = true)
FileUtils.makedirs(templates_root)

new_coversheet_path = templates_root.join("#{flow_name.underscore}.govspeak.erb")
File.open(new_coversheet_path, 'w') do |file|
  file.puts '<% content_for :title do %>'
  file.puts coversheet_title.indent(2)
  file.puts '<% end %>'
  file.puts ''
  file.puts '<% content_for :meta_description do %>'
  file.puts coversheet_meta_description.indent(2)
  file.puts '<% end %>'
  file.puts ''
  file.puts '<% content_for :body do %>'
  file.puts coversheet_body.indent(2)
  file.puts '<% end %>'
end

input.outcomes.each do |outcome|
  template_path = templates_root.join("#{outcome.name.underscore}.govspeak.erb")
  body = outcome.read
  # regular expression copied from Smartdown::Parser::SnippetPreParser#parse_content
  body.gsub!(/\{\{snippet:\W?(.*)\}\}/i) do
    "<%= render partial: '#{$1.underscore}.govspeak.erb' -%>"
  end
  # regular expression copied from Smartdown::Engine::Interpolator#interpolate
  body.gsub!(/%{([^}]+)}/) do
    raise "Outcome '#{outcome.name.underscore}' includes interpolated value '#{$1}' which is not yet supported by this conversion tool"
  end
  File.open(template_path, 'w') do |file|
    file.puts '<% content_for :body do %>'
    file.puts body.indent(2)
    file.puts '<% end %>'
  end
end

input.snippets.each do |snippet|
  template_path = templates_root.join("_#{snippet.name.underscore}.govspeak.erb")
  File.open(template_path, 'w') do |file|
    file.puts snippet.read
  end
end
