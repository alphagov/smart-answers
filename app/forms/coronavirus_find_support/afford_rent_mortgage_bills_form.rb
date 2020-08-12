module CoronavirusFindSupport
  class AffordRentMortgageBillsForm < Form
    answer_flow :coronavirus_find_support
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
