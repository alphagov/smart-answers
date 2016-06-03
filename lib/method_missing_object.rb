class MethodMissingObject
  def initialize(method, parent_method = nil, blank_to_s = false, to_s_overrides = {})
    @method = method
    @parent_method = parent_method
    @blank_to_s = blank_to_s
    @to_s_overrides = to_s_overrides
  end

  def method_missing(method, *_args, &_block)
    MethodMissingObject.new(method, self, @blank_to_s, @to_s_overrides)
  end

  def description
    @parent_method ? "#{@parent_method.description}.#{@method}" : @method.to_s
  end

  def to_s
    @to_s_overrides.fetch(description) do
      @blank_to_s ? "" : "<%= #{description} %>".html_safe
    end
  end

  alias to_str to_s
end
