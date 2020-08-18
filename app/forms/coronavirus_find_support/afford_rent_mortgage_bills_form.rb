module CoronavirusFindSupport
  class AffordRentMortgageBillsForm < Form
    answer_flow :coronavirus_find_support
    answer_node :afford_rent_mortgage_bills

    validates :afford_rent_mortgage_bills, presence: { message: t("errors.blank") }

    def options
      %i[yes no not_sure]
    end

    def prepare_session
      session[flow_name] ||= {}
      session[flow_name]["paying_bills"] ||= {}
    end

    def update_session
      session[flow_name]["paying_bills"][node_name] = data_to_be_stored_in_session
    end
  end
end
