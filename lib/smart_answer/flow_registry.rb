module SmartAnswer
  class FlowRegistry
    class NotFound < StandardError; end
    FLOW_DIR = Rails.root.join("app/flows")

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
        class_name = File.basename(path, ".rb").camelize
        class_name.constantize.build
      end
    end

    def find(name)
      @flows.find { |flow| flow.name == name } || raise(NotFound, "'#{name}' not found")
    end
  end
end
