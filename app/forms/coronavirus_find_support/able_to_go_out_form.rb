module CoronavirusFindSupport
  class AbleToGoOutForm < Form
    answer_flow :coronavirus_find_support
    answer_node :able_to_go_out

    validates :able_to_go_out, presence: { message: t("errors.blank") }

    def options
      %i[
        yes
        no_i_have_coronavirus
        no_i_have_a_medical_condition
        no_i_have_a_disability
        no_for_another_reason
      ]
    end

    def prepare_session
      session[flow_name] ||= {}
      session[flow_name]["getting_food"] ||= {}
    end

    def update_session
      session[flow_name]["getting_food"][node_name] = data_to_be_stored_in_session
    end
  end
end
