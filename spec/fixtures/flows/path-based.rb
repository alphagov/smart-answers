module SmartAnswer
  class PathBasedFlow < Flow
    def define
      name "path-based"
      satisfies_need "cccab629-bd2b-3f02-9af7-30f58555ac41"
      start_page_content_id "d26e566e-1550-4913-b945-9372c32256f1"

      value_question :question1 do
        next_node do
          outcome :results
        end
      end

      outcome :results
    end
  end
end
