module CoronavirusFindSupport
  class AffordFoodForm < Form
    answer_flow :coronavirus_find_support
    answer_node :afford_food

    def options
      {
        yes: "Yes",
        no: "No",
        not_sure: "Not sure",
      }
    end
  end
end
