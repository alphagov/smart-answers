module CoronavirusFindSupport
  class GetFoodForm < Form
    answer_flow :coronavirus_find_support
    answer_node :get_food

    def options
      {
        yes: "Yes",
        no: "No",
        not_sure: "Not sure",
      }
    end
  end
end
