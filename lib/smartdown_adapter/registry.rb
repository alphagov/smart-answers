require 'smartdown/api/flow'
require 'smartdown/api/directory_input'

module SmartdownAdapter
  class Registry

    def self.instance
      @instance ||= new(FLOW_REGISTRY_OPTIONS)
    end

    def self.reset_instance
      @instance = nil
    end

    def initialize(options = {})
      @load_path = Pathname.new(options[:load_path] || Rails.root.join('lib', 'smartdown_flows'))
      @show_drafts = options.fetch(:show_drafts, false)
      @show_transitions = options.fetch(:show_transitions, false)
      preload_flows! if options.fetch(:preload_flows, Rails.env.production?)
    end

    private_class_method :new

    def check(name, options = FLOW_REGISTRY_OPTIONS)
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
        available_flows.map { |f| build_flow(f) }
      end
    end

    private

    def find_by_name(name)
      @preloaded ? @preloaded[name] : build_flow(name)
    end

    def build_flow(name)
      input = Smartdown::Api::DirectoryInput.new(coversheet_path(name))
      Smartdown::Api::Flow.new(input, build_plugins)
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

    def available_flows
      flow_paths = Dir[@load_path.join('*')].select { |p| File.directory?(@load_path.join(p)) }
      flow_paths.map { |p| File.basename(p) }
    end

    def preload_flows!
      @preloaded = {}
      available_flows.each do |flow_name|
        @preloaded[flow_name] = build_flow(flow_name)
      end
    end

  private
    def build_plugins
      {}.tap {|plugins|
        SmartdownAdapter::Plugins.constants.each { |plugin_name|
          plugin = SmartdownAdapter::Plugins.const_get plugin_name
          plugins[plugin.key] = plugin.new
        }
      }
    end
  end
end
