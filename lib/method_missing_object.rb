class MethodMissingObject
  def initialize(method, parent_method = nil, blank_to_s = false, overrides = {})
    @method = method
    @parent_method = parent_method
    @blank_to_s = blank_to_s
    @overrides = overrides
  end

  def respond_to_missing?(*_args)
    true
  end

  def method_missing(method, *_args, &_block)
    object = MethodMissingObject.new(method, self, @blank_to_s, @overrides)
    @overrides.fetch(object.description) { object } || super
  end

  def description
    @parent_method ? "#{@parent_method.description}.#{@method}" : @method.to_s
  end

  def to_s
    @blank_to_s ? "" : "<%= #{description} %>".html_safe
  end

  alias to_str to_s
end
