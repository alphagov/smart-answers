namespace :hint_and_body_finder do
    desc "todo"
    task :find => :environment do

        flow_registry = SmartAnswer::FlowRegistry.new(FLOW_REGISTRY_OPTIONS)
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
end
