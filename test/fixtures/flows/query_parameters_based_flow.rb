class QueryParametersBasedFlow < SmartAnswer::Flow
  def define
    name "query-parameters-based"
    content_id "f26e566e-2557-4921-b944-9373c32255f1"
    response_store :query_parameters

    radio :question1 do
      option :response1
      option :response2

      next_node do
        question :question2
      end
    end

    value_question :question2 do
      next_node do
        outcome :results
      end
    end

    outcome :results
  end
end
