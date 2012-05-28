class CountrySelectQuestionPresenter < MultipleChoiceQuestionPresenter

  def options
    @node.options.map do |option|
      OpenStruct.new(label: option[:name], value: option[:slug])
    end
  end

end