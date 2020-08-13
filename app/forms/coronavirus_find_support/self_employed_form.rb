module CoronavirusFindSupport
  class SelfEmployedForm < Form
    answer_flow :coronavirus_find_support
    answer_node :self_employed

    validates :self_employed, presence: { message: t("errors.blank") }

    def options
      %i[yes no not_sure]
    end

    def prepare_session
      session[flow_name] ||= {}
      session[flow_name]["being_unemployed"] ||= {}
    end

    def update_session
      session[flow_name]["being_unemployed"][node_name] = data_to_be_stored_in_session
    end
  end
end
