class CountrySelectQuestionPresenter < QuestionPresenter
  include CurrentQuestionHelper

  def select_options
    @node.options.map do |option|
      {
        text: option.name,
        value: option.slug,
        selected: option.slug == prefill_value_for(self),
      }
    end
  end

  def response_label(value)
    select_options.find { |option| option[:value] == value }[:text]
  end
end
