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

    def self.smartdown_transition_questions
      smartdown_questions.select { |name|
        smartdown_flow = build_flow(name)
        smartdown_flow.transition?
      }
    end

    def self.build_flow(name)
      coversheet_path = Rails.root.join('lib', 'smartdown_flows', name, "#{name}.txt")
      input = Smartdown::Api::DirectoryInput.new(coversheet_path)
      Smartdown::Api::Flow.new(input)
    end

    def self.check(name, options = FLOW_REGISTRY_OPTIONS)
      return unless self.smartdown_questions.include? name

      flow = self.build_flow(name)

      return true if flow.published?
      return true if options[:show_transitions] && flow.transition?
      return true if options[:show_drafts] && (flow.draft? || flow.transition?)
    end

    def self.flows
      # @TODO: Refactor, this calls build_flow twice
      self.smartdown_questions.map { |name| build_flow(name) if check(name) }.compact
    end
  end
end
