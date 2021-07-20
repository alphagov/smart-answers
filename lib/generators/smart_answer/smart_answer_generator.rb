class SmartAnswerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def copy_flow
    filename = "app/flows/#{name.underscore}_flow.rb"
    copy_file "flow.rb", filename

    gsub_file filename, "SmartAnswerName", name.camelize

    inject_into_file filename, after: "def define\n" do
      <<-RUBY
      name "#{name.dasherize}"
      content_id "#{SecureRandom.uuid}"
      status :draft
      RUBY
    end
  end

  def copy_landing
    filename = "app/flows/#{name.underscore}_flow/start.erb"
    copy_file "landing.erb", filename

    gsub_file filename, "TITLE", name.humanize
  end

  def copy_question
    filename = "app/flows/#{name.underscore}_flow/questions/question.erb"
    copy_file "question.erb", filename
  end

  def copy_results
    filename = "app/flows/#{name.underscore}_flow/outcomes/results.erb"
    copy_file "results.erb", filename
  end

  def copy_calculator
    filename = "lib/smart_answer/calculators/#{name.underscore}_calculator.rb"
    copy_file "calculator.rb", filename

    gsub_file filename, "SmartAnswerName", name.camelize.to_s
  end
end
