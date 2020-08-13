module SessionAnswersHelper
  def items_for_error_summary(form)
    form.errors.each_with_object([]) do |(attr, message), array|
      array << { text: message, href: "##{attr}" }
    end
  end

  def error_summary(form, attribute)
    messages = form.errors[attribute]
    return if messages.empty?

    messages.to_sentence
  end
end
