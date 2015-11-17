class MethodMissingObject
  def initialize(method, parent_method = nil)
    @method = method
    @parent_method = parent_method
  end

  def method_missing(method, *args, &block)
    MethodMissingObject.new(method, self)
  end

  def description
    @parent_method ? "#{@parent_method.description}.#{@method}" : @method
  end

  def to_s
    "<%= #{description} %>".html_safe
  end
end
