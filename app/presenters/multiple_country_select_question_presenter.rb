class MultipleCountrySelectQuestionPresenter < QuestionPresenter
  def select_count
    @node.select_count
  end

  def select_options
    @node.options.map(&:name)
  end

  def parsed_response
    puts "parsed_response [#{current_response}]...."
    return [] if current_response == "|||"

  #   return current_response if current_response.is_a?(Hash)
  #
  #   salary = @node.parse_input(current_response)
  #   {
  #     amount: salary.amount,
  #     period: salary.period,
  #   }
  # rescue SmartAnswer::InvalidResponse
    []
  end

  def error
    if @state.error.present?
      puts "error called [#{current_response}]...."
      return [ { text: "Please select at least one country"} ] if current_response.values.reject(&:empty?).empty?

      # error_message_for(@state.error) || error_message_for("error_message") || default_error_message
    end

    # TODO: generate errors if blank (i.e. no countries are given)
    # or when given country names are not in the `select_options`.
    # Ideally, should be an Array, e.g.
    # ["Not a real country", "", "Not a real country"]
    # so that the index used on /app/views/smart_answers/inputs/_multiple_country_select_question.html.erb
    # [
    #   { text: "Not a real country" },
    #   { text: "" },
    #   { text: "Not a real country" },
    #   { text: "" },
    # ]
    []
  end
end
