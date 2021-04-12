class MethodMissingObject
  def initialize(method, parent_method: nil, blank_to_s: false, overrides: {})
    @method = method
    @parent_method = parent_method
    @blank_to_s = blank_to_s
    @overrides = overrides
  end

  # rubocop:disable Style/MissingRespondToMissing
  def method_missing(method, *_args, &_block)
    object = MethodMissingObject.new(method,
                                     parent_method: self,
                                     blank_to_s: @blank_to_s,
                                     overrides: @overrides)
    @overrides.fetch(object.description) { object }
  end
  # rubocop:enable Style/MissingRespondToMissing

  def description
    @parent_method ? "#{@parent_method.description}.#{@method}" : @method.to_s
  end

  def to_s(_format = nil)
    @blank_to_s ? "" : "<%= #{description} %>".html_safe
  end

  alias_method :to_str, :to_s
end
