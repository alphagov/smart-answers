require 'smartdown/api/flow'
require 'smartdown/api/directory_input'

module SmartdownAdapter
  class Registry
    def self.instance(options = FLOW_REGISTRY_OPTIONS)
      if @options && @options != options
        raise "Unexpected modification of flow registry options, got #{options} and had #{@options}"
      end
      @options = options
      @instance ||= new(options)
    end

    def self.reset_instance
      @instance = nil
      @options = nil
    end

    def initialize(options = {})
      @load_path = Pathname.new(options[:smartdown_load_path] || Rails.root.join('lib', 'smartdown_flows'))
      @show_drafts = options.fetch(:show_drafts, false)
      @show_transitions = options.fetch(:show_transitions, false)
      preload_flows! if options.fetch(:preload_flows, Rails.env.production?)
    end

    private_class_method :new

    def check(name)
      return unless available?(name)

      flow = @preloaded ? @preloaded[name] : build_flow(name)

      return true if flow.published?
      return true if @show_transitions && flow.transition?
      return true if @show_drafts && (flow.draft? || flow.transition?)
    end

    def find(name)
      find_by_name(name) if check(name)
    end

    def flows
      if @preloaded
        @preloaded.values
      else
        available_flows.select { |n| check(n) }.map { |f| build_flow(f) }
      end
    end

    def available_flows
      flow_paths = Dir[@load_path.join('*')].select { |p| File.directory?(@load_path.join(p)) }
      flow_paths.map { |p| File.basename(p) }
    end

  private
    def find_by_name(name)
      @preloaded ? @preloaded[name] : build_flow(name)
    end

    def build_flow(name)
      input = Smartdown::Api::DirectoryInput.new(coversheet_path(name))
      Smartdown::Api::Flow.new(input, initial_state: get_render_time_plugins(name), data_module: get_build_time_plugins(name))
    end

    def coversheet_path(name)
      @load_path.join(name, "#{name}.txt")
    end

    def available?(name)
      if @preloaded
        @preloaded.has_key?(name)
      else
        available_flows.include?(name)
      end
    end

    def preload_flows!
      @preloaded = {}
      available_flows.each do |flow_name|
        @preloaded[flow_name] = build_flow(flow_name)
      end
      @preloaded.select! { |k, v| check(v.name) }
    end

    def get_render_time_plugins(flow_name)
      plugin_factory(flow_name)[:render_time]
    end

    def get_build_time_plugins(flow_name)
      plugin_factory(flow_name)[:build_time]
    end

    def plugin_factory(flow_name)
      @factory ||= {}
      @factory[flow_name] ||= PluginFactory.for(flow_name)
    end
  end
end
