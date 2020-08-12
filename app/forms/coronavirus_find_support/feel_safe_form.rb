module CoronavirusFindSupport
  class FeelSafeForm < Form
    answer_flow :coronavirus_find_support
    answer_node :feel_safe

    def options
      {
        yes: "Yes",
        yes_but_i_am_concerned_about_others: "Yes, but I’m worried about the safety of another adult or a child",
        no: "No",
        not_sure: "Not sure",
      }
    end
  end
end
