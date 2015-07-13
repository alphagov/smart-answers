module SmartAnswer
  class FlowRegistry
    class NotFound < StandardError; end
    FLOW_DIR = Rails.root.join('lib', 'smart_answer_flows')

    def self.instance
      @instance ||= new(FLOW_REGISTRY_OPTIONS)
    end

    def self.reset_instance
      @instance = nil
    end

    def initialize(options = {})
      @load_path = Pathname.new(options[:smart_answer_load_path] || FLOW_DIR)
      @show_drafts = options.fetch(:show_drafts, false)
      @show_transitions = options.fetch(:show_transitions, false)
      preload_flows! if Rails.env.production? or options[:preload_flows]
    end
    attr_reader :load_path

    def find(name)
      raise NotFound unless available?(name)
      find_by_name(name) or raise NotFound
    end

    def flows
      available_flows.map { |s| find_by_name(s) }.compact
    end

    def available_flows
      Dir[@load_path.join('*.rb')].map do |path|
        File.basename(path, ".rb")
      end
    end

  private
    def find_by_name(name)
      flow = @preloaded ? preloaded(name) : build_flow(name)
      return nil if flow && flow.draft? && !@show_drafts
      return nil if flow && flow.transition? && !@show_transitions
      flow
    end

    def available?(name)
      if @preloaded
        @preloaded.has_key?(name)
      else
        available_flows.include?(name)
      end
    end

    def build_flow(name)
      class_prefix = name.gsub("-", "_").camelize
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
