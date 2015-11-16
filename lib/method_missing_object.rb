class MethodMissingObject
  def initialize(method, parent_method = nil, blank_to_s = false)
    @method = method
    @parent_method = parent_method
    @blank_to_s = blank_to_s
  end

  def method_missing(method, *args, &block)
    MethodMissingObject.new(method, parent_method = self, blank_to_s = @blank_to_s)
  end

  def description
    @parent_method ? "#{@parent_method.description}.#{@method}" : @method
  end

  def to_s
    @blank_to_s ? "" : "<%= #{description} %>".html_safe
  end
end
