module CoronavirusFindSupport
  class AreYouOffWorkIllForm < Form
    answer_flow :coronavirus_find_support
    answer_node :are_you_off_work_ill

    validates :are_you_off_work_ill, presence: { message: t("errors.blank") }

    def options
      %i[yes no]
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
