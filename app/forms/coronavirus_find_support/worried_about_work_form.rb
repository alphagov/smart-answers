module CoronavirusFindSupport
  class WorriedAboutWorkForm < Form
    answer_flow :coronavirus_find_support
    answer_node :worried_about_work

    validates :worried_about_work, presence: { message: t("errors.blank") }

    def options
      %i[yes no not_sure]
    end

    def prepare_session
      session[flow_name] ||= {}
      session[flow_name]["going_to_work"] ||= {}
    end

    def update_session
      session[flow_name]["going_to_work"][node_name] = data_to_be_stored_in_session
    end
  end
end
