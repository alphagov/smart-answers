class ListValidator
  def initialize(list)
    @list = list
  end

  def all_valid?(elements)
    elements.present? &&
      elements.is_a?(Array) &&
      elements.all? { |element| @list.include?(element) }
  end
end
