module CoronavirusFindSupport
  class AffordRentMortgageBillsForm < Form
    attr_accessor :afford_rent_mortgage_bills

    validates :afford_rent_mortgage_bills,
              presence: { message: "Select yes if you’re finding it hard to pay your rent, mortgage or bills" }

    def options
      {
        yes: "Yes",
        no: "No",
        not_sure: "Not sure",
      }
    end
  end
end
