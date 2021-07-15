module SmartAnswer
  class FlowRegistry
    class NotFound < StandardError; end
    FLOW_DIR = Rails.root.join("lib/smart_answer_flows")

    attr_reader :flows, :load_path

    def self.instance
      @instance ||= new
    end

    def self.reset_instance(options = {})
      @instance = new(options)
    end

    def initialize(options = {})
      @load_path = Pathname.new(options.fetch(:smart_answer_load_path, FLOW_DIR))
      @flows = Dir[@load_path.join("*.rb")].map do |path|
        build_flow(File.basename(path, ".rb"))
      end
    end

    def find(name)
      @flows.find { |flow| flow.name == name } || raise(NotFound, "'#{name}' not found")
    end

  private

    def build_flow(name)
      class_prefix = name.tr("-", "_").camelize
      namespaced_class = "#{class_prefix}Flow".constantize
      namespaced_class.build
    end
  end
end
