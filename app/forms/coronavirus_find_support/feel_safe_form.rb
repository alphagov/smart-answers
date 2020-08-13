module CoronavirusFindSupport
  class FeelSafeForm < Form
    answer_flow :coronavirus_find_support
    answer_node :feel_safe

    validates :feel_safe, presence: { message: t("errors.blank") }

    def options
      %i[
        yes
        yes_but_i_am_concerned_about_others
        no
        not_sure
      ]
    end

    def prepare_session
      session[flow_name] ||= {}
      session[flow_name]["feeling_unsafe"] ||= {}
    end

    def update_session
      session[flow_name]["feeling_unsafe"][node_name] = data_to_be_stored_in_session
    end
  end
end
