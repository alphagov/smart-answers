class PartialTemplateRenderInterceptor
  def self.[](handler)
    Module.new do
      define_method :render do |*args|
        result = super(*args)
        identifier = @template ? @template.identifier : @path
        handler.call(identifier, result)
      end
    end
  end
end
