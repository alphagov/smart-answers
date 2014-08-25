require 'smartdown/api/flow'
require 'smartdown/api/directory_input'

module SmartdownAdapter
  class Registry

    def self.smartdown_questions
      smartdown_directory_path = Rails.root.join('lib', 'smartdown_flows')
      Dir.entries(smartdown_directory_path).select {|entry|
        File.directory? File.join(smartdown_directory_path, entry) and !(entry =='.' || entry == '..')
      }
    end

    def self.build_flow(name)
      coversheet_path = Rails.root.join('lib', 'smartdown_flows', name, "#{name}.txt")
      input = Smartdown::Api::DirectoryInput.new(coversheet_path)
      Smartdown::Api::Flow.new(input)
    end

    def self.flows(options = FLOW_REGISTRY_OPTIONS)
      show_drafts = options.fetch(:show_drafts, false)
      show_transitions = options.fetch(:show_transitions, false)
      smartdown_questions.map { |smartdown_question|
        build_flow(smartdown_question)
      }.select { |flow|
        (flow.draft? && show_drafts) || (flow.transition? && show_transitions)
      }
    end

    def self.check(name, options = FLOW_REGISTRY_OPTIONS)
      show_drafts = options.fetch(:show_drafts, false)
      use_smartdown_question = false
      if smartdown_questions.include? name
        smartdown_flow = build_flow(name)
        use_smartdown_question = (smartdown_flow && smartdown_flow.draft? && show_drafts) ||
        (smartdown_flow && smartdown_flow.published?)
      end
      use_smartdown_question
    end

    def self.check_transition_question(name)
      if smartdown_questions.include? name
        smartdown_flow = build_flow(name)
        return smartdown_flow && smartdown_flow.transition?
      end
      false
    end
  end
end
