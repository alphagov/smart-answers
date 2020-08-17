module CoronavirusFindSupport
  class AffordRentMortgageBillsForm < Form
    answer_flow :coronavirus_find_support
    answer_node :afford_rent_mortgage_bills

    validates :afford_rent_mortgage_bills, presence: { message: t("errors.blank") }

    def options
      %i[yes no not_sure]
    end
  end
end
