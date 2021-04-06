class SmartAnswerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_flow
    filename = "lib/smart_answer_flows/#{name.dasherize}.rb"
    copy_file "flow.rb", filename

    gsub_file filename, "SmartAnswerName", name.camelize

    inject_into_file filename, after: "def define\n" do
      <<-RUBY
      name "#{name.dasherize}"
      content_id "#{SecureRandom.uuid}"
      flow_content_id "#{SecureRandom.uuid}"
      status :draft
      RUBY
    end
  end

  def copy_landing
    filename = "lib/smart_answer_flows/#{name.dasherize}/#{name.underscore}.erb"
    copy_file "landing.erb", filename

    gsub_file filename, "TITLE", name.humanize
  end

  def copy_question
    filename = "lib/smart_answer_flows/#{name.dasherize}/questions/question.erb"
    copy_file "question.erb", filename
  end

  def copy_results
    filename = "lib/smart_answer_flows/#{name.dasherize}/outcomes/results.erb"
    copy_file "results.erb", filename
  end

  def copy_calculator
    filename = "lib/smart_answer/calculators/#{name.underscore}_calculator.rb"
    copy_file "calculator.rb", filename

    gsub_file filename, "SmartAnswerName", name.camelize.to_s
  end
end
