module CoronavirusFindSupport
  class MentalHealthWorriesForm < Form
    answer_flow :coronavirus_find_support
    answer_node :mental_health_worries

    validates :mental_health_worries, presence: { message: t("errors.blank") }

    def options
      %i[yes no not_sure]
    end

    def prepare_session
      session[flow_name] ||= {}
      session[flow_name]["mental_health"] ||= {}
    end

    def update_session
      session[flow_name]["mental_health"][node_name] = data_to_be_stored_in_session
    end
  end
end
