unless flow_path = Rails.root.join(ARGV.shift)
  puts "Usage: #{__FILE__} <relative-path-to-flow-directory> e.g. lib/smart_answer_flows/additional-commodity-code"
  exit 1
end

def normalize_blank_lines(string)
  string.gsub(/(\n$){2,}/m, "\n")
end

flow_name = File.basename(flow_path)

yaml_path = flow_path.join('..', 'locales', 'en', flow_name + '.yml')
yaml = YAML.load_file(yaml_path)

questions_root = flow_path.join('questions')
FileUtils.mkdir_p(questions_root)

keys = yaml['en-GB']['flow'][flow_name]

questions = keys.except('phrases')
questions.each do |question_key, attributes|
  attributes ||= {}
  options_erb = nil
  options = attributes['options']
  if options.present?
    rendered_options = options.inject([]) do |array, (key, value)|
      array << "#{key.to_s.inspect}: #{value.inspect}".indent(2)
      array
    end
    options_erb = "<% options(\n#{rendered_options.join(",\n")}\n) %>"
  end
  error_attributes = attributes.except(*%w(title options hint label suffix_label body post_body))
  errors = error_attributes.inject([]) do |array, (key, value)|
    array << "<% content_for #{key.to_sym.inspect} do %>"
    array << value.indent(2)
    array << "<% end %>"
    array
  end
  errors_erb = errors.join("\n")
  erb = File.read(Rails.root.join('script', 'templates', 'question.erb'))
  template = Erubis::Eruby.new(erb)
  template_name = question_key.sub(/\?$/, '') + '.govspeak.erb'
  content = normalize_blank_lines(template.result(binding))
  print "Writing template: #{template_name}"
  if content =~ /%{[^}]+}/
    puts " (WARNING: contains interpolation)"
  else
    puts
  end
  File.open(questions_root.join(template_name), 'w') do |file|
    file.write(content)
  end
end

phrases = keys['phrases']
if phrases.present?
  puts "\nWARNING: i18n YAML file contains phrases"
  phrases.each do |key, value|
    puts "* #{key}: #{value.inspect}".indent(2)
  end
end

puts "\nDeleting i18n YAML: #{File.basename(yaml_path)}"
FileUtils.rm(yaml_path)

puts "\nNow insert `use_erb_templates_for_questions` at top of flow: #{flow_name}.rb"
