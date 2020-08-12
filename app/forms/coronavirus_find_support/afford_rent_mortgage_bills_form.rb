module CoronavirusFindSupport
  class AffordRentMortgageBillsForm < Form
    answer_flow :session_answers
    answer_node :afford_rent_mortgage_bills

    def options
      {
        yes: "Yes",
        no: "No",
        not_sure: "Not sure",
      }
    end
  end
end
