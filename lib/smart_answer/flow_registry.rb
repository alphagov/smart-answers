module SmartAnswer
  class FlowRegistry
    class NotFound < StandardError; end

    def initialize(options={})
      @load_path = Pathname.new(options[:load_path] || Rails.root.join('lib', 'flows'))
      @show_drafts = options[:show_drafts]
      preload_flows! if Rails.env.production?
    end

    def find(name)
      raise NotFound unless available?(name)
      find_by_name(name) or raise NotFound
    end

    def flows
      available_flows.map { |s| find_by_name(s) }.compact
    end

  private
    def find_by_name(name)
      absolute_path = @load_path.join("#{name}.rb").to_s
      flow = preloaded(name) || Flow.new {
        eval(File.read(absolute_path), binding, absolute_path)
        name(name)
      }
      return nil if flow && flow.draft? && !@show_drafts
      flow
    end

    def available?(name)
      available_flows.include?(name)
    end

    def available_flows
      Dir[@load_path.join('*.rb')].map do |path|
        File.basename(path, ".rb")
      end
    end

    def preload_flows!
      @preloaded = {}
      available_flows.each do |flow_name|
        @preloaded[flow_name] = find_by_name(flow_name)
      end
    end

    def preloaded(name)
      @preloaded && @preloaded[name]
    end
  end
end
