class ListValidator
  def self.call(constraint: {}, test: [])
    test.map!(&:to_sym)
    new(constraint.keys).all_valid?(test)
  end

  attr_reader :list

  def initialize(list)
    @list = list
  end

  def all_valid?(elements)
    return false unless elements.present? && elements.is_a?(Array)

    (elements - list).empty?
  end
end
