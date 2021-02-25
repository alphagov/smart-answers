module SmartAnswer
  class TestFlow < Flow
    def define
      name "test"
      satisfies_need "dccab509-bd3b-4f92-9af6-30f88485ac41"
      start_page_content_id "f26e566e-2557-4921-b944-9373c32255f1"
      response_store :session

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
end
