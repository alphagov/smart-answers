namespace :smartdown_scenarios do

  desc "Run all scenarios for all Smartdown questions"
  task :all => :environment do
    report = {}
    smartdown_flows = SmartdownAdapter::Registry.instance.flows
    smartdown_flows.each do |smartdown_flow|
      smartdown_flow.scenario_sets.each do |scenario_set|
        error_report = check_scenario_set(smartdown_flow, scenario_set)
        unless error_report.empty?
          report[smartdown_flow.name] = error_report
        end
      end
    end
    print_report(report)
  end

  desc "Rename a Smartdown directory package, including coversheet"
  task :run, [:name] => :environment do |t, args|
    report = Hash.new
    smartdown_flow = SmartdownAdapter::Registry.instance.find(args[:name])
    smartdown_flow.scenario_sets.each do |scenario_set|
      error_report = check_scenario_set(smartdown_flow, scenario_set)
      unless error_report.keys.empty?
        report[smartdown_flow.name] = error_report
      end
    end
    print_report(report)
  end

  def check_scenario_set(smartdown_flow, scenario_set)
    report = Hash.new
    scenario_set.scenarios.each_with_index do |scenario, scenario_index|
      description = scenario.description.empty? ? scenario_index+1 : scenario.description
      scenario_errors = check_scenario(smartdown_flow, scenario)
      unless scenario_errors.empty?
        scenario_description = "Set #{scenario_set.name}, scenario #{description}"
        report[scenario_description] = scenario_errors
      end
    end
    report
  end

  def check_scenario(smartdown_flow, scenario)
    errors = []
    scenario.question_groups.each_with_index do |question_group, question_index|
      answers = scenario.question_groups.take(question_index).flatten.map(&:answer)
      question_names = question_group.map(&:name)
      errors = check_questions(smartdown_flow, answers, question_names, errors)
    end
    answers = scenario.question_groups.flatten.map(&:answer)
    check_outcome(smartdown_flow, answers, scenario.outcome, errors)
  end

  def check_questions(flow, answers, question_names, errors)
    begin
      state  = flow.state(true, answers)
      if !(state.current_node.is_a? Smartdown::Api::QuestionPage)
        errors << "Did not get a question for answers #{answers.join(",")}"
      else
        current_question_names = state.current_node.questions.map(&:name).map(&:to_s)
        question_names.each do |question_name|
          if !current_question_names.include?(question_name)
            errors << "Questions #{current_question_names} reached but not #{question_name}"
          end
        end
      end
    rescue Exception => e
      require 'pry'
      binding.pry
      errors << "Exception thrown for answers #{answers.join(",")}"
    end
    errors
  end

  def check_outcome(flow, answers, outcome, errors)
    begin
      state  = flow.state(true, answers)
      if !(state.current_node.is_a? Smartdown::Api::Outcome)
        errors << "Did not get an outcome for answers #{answers.join(",")}"
      elsif outcome != state.current_node.name
        errors << "Outcome #{state.current_node.name} reached and not #{outcome} with answers #{answers.join(",")}"
      end
    rescue Exception => e
      require 'pry'
      binding.pry
      errors << "Exception thrown for answers #{answers.join(",")}"
    end
    errors
  end

  def print_report(report)
    unless report.keys.empty?
      report.each do |flow_name, error_report|
        p "============================="
        p "ERRORS FOR FLOW #{flow_name}"
        error_report.each do |scenario_line, error_lines|
          p "-----------------------------"
          p scenario_line
          error_lines.each do |error_line|
            p error_line
          end
        end
      end
      fail
    end
  end
end
