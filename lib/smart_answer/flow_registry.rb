module SmartAnswer
  class FlowRegistry
    class NotFound < StandardError; end
    FLOW_DIR = Rails.root.join("lib/smart_answer_flows")

    def self.instance
      @instance ||= new
    end

    def self.reset_instance(options = {})
      @instance = new(options)
    end

    def initialize(options = {})
      @load_path = Pathname.new(options[:smart_answer_load_path] || FLOW_DIR)
      preload_flows! if !Rails.env.development? || options[:preload_flows]
    end
    attr_reader :load_path
    def find(name)
      raise NotFound, "'#{name}' not found" unless available?(name)

      find_by_name(name) || raise(NotFound)
    end

    def flows
      available_flows.map { |s| find_by_name(s) }.compact
    end

    def available_flows
      Dir[@load_path.join("*.rb")].map do |path|
        File.basename(path, ".rb")
      end
    end

    def preloaded?
      @preloaded.present?
    end

  private

    def find_by_name(name)
      @preloaded ? preloaded(name) : build_flow(name)
    end

    def available?(name)
      if @preloaded
        @preloaded.key?(name)
      else
        available_flows.include?(name)
      end
    end

    def build_flow(name)
      class_prefix = name.tr("-", "_").camelize
      if Rails.env.development?
        load @load_path.join("#{name}.rb")
      else
        require @load_path.join(name)
      end
      namespaced_class = "SmartAnswer::#{class_prefix}Flow".constantize
      namespaced_class.build
    end

    def preload_flows!
      @preloaded = {}
      available_flows.each do |flow_name|
        @preloaded[flow_name] = build_flow(flow_name)
      end
    end

    def preloaded(name)
      @preloaded && @preloaded[name]
    end
  end
end
