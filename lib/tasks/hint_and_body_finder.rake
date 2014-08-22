namespace :hint_and_body_finder do

    registry_options = {show_drafts: false, show_transitions: false}

    desc "todo"
    task :find => :environment do

        flow_registry = SmartAnswer::FlowRegistry.new(registry_options)
        flow_registry.flows.each do |flow|
            flow.questions.each do |question|
                question = QuestionPresenter.new("flow.#{flow.name}", question)
                begin
                    if question.hint and question.body
                        puts "#{flow.name}.#{question.name}"
                    end
                rescue I18n::MissingInterpolationArgument
                    nil
                end
            end
        end
    end

    desc "todo"
    task :find_raw => :environment do

        flow_registry = SmartAnswer::FlowRegistry.new(registry_options)
        flow_registry.flows.each do |flow|
            file_path = "lib/smart_answer_flows/locales/en/#{flow.name}.yml"
            if !File.exists?(file_path)
                puts "Couldn't find matching yml file for #{flow.name}"
                next
            end
            yml_flow = YAML.load_file(file_path)["en-GB"]["flow"][flow.name]

            questions = yml_flow.select { |key, val| key.ends_with? "?" }
            questions.each do |question_name, question|
                if question['hint'].present? and question['body'].present?
                    puts "#{flow.name}.#{question_name}"
                end
            end
        end
    end
end
