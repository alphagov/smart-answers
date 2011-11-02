module SmartAnswer
  class FlowRegistry
    class NotFound < StandardError; end
    
    def initialize(load_path = nil)
      @load_path = Pathname.new(load_path) || Rails.root.join('lib', 'flows')
      preload_flows! if Rails.env.production?
    end
    
    def find(name)
      raise NotFound unless available?(name)
      absolute_path = @load_path.join("#{name}.rb").to_s
      preloaded(name) || Flow.new do
        eval(File.read(absolute_path), binding, absolute_path)
      end
    end
    
    def available?(name)
      available_flows.include?(name)
    end
    
    def available_flows
      Dir[@load_path.join('*.rb')].map do |path|
        File.basename(path).gsub(/\.rb$/, '')
      end
    end
    
    def preload_flows!
      @preloaded = {}
      available_flows.each do |flow_name|
        @preloaded[flow_name] = find(flow_name)
      end
    end
    
    def preloaded(name)
      @preloaded && @preloaded[name]
    end
  end
end