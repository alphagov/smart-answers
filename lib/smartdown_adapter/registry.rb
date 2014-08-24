require 'smartdown/api/directory_input'
require 'smartdown/api/flow'

module SmartdownAdapter
  class Registry

    @@load_path = Rails.root.join('lib', 'smartdown_flows')

    def self.build_flow(name)
      coversheet_path = File.join([@@load_path, name, "#{name}.txt"])
      # @TODO: Should wrapped by a Smartdown::Api class to hide internals
      input = Smartdown::Api::DirectoryInput.new(coversheet_path)
      Smartdown::Api::Flow.new(input)
    end

    def self.smartdown_questions
      Dir.entries(@@load_path).select {|entry|
        File.directory? File.join(@@load_path, entry) and !(entry =='.' || entry == '..')
      }
    end

    def self.smartdown_transition_questions
      smartdown_questions.select { |smartdown_question_name|
        smartdown_flow = build_flow(smartdown_question_name)
        smartdown_flow.transition?
      }
    end

    def self.check(name, options = FLOW_REGISTRY_OPTIONS)
      show_drafts = options.fetch(:show_drafts, false)
      show_transitions = options.fetch(:show_transitions, false)
      use_smartdown_question = false
      if self.smartdown_questions.include? name
        smartdown_flow = build_flow(name)
        use_smartdown_question = (smartdown_flow && smartdown_flow.draft? && show_drafts) ||
        (smartdown_flow && smartdown_flow.transition? && show_transitions) ||
        (smartdown_flow && smartdown_flow.published?)
      end
      use_smartdown_question
    end
  end
end
