module SmartAnswer
  class PathBasedFlow < Flow
    def define
      name "path-based"
      content_id "d26e566e-1550-4913-b945-9372c32256f1"

      start_page

      value_question :question1 do
        next_node do
          outcome :results
        end
      end

      outcome :results
    end
  end
end
