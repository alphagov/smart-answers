module CoronavirusFindSupport
  class HaveYouBeenMadeUnemployedForm < Form
    answer_flow :coronavirus_find_support
    answer_node :have_you_been_made_unemployed

    validates :have_you_been_made_unemployed, presence: { message: t("errors.blank") }

    def options
      %i[
        yes_i_have_been_made_unemployed
        yes_i_have_been_put_on_furlough
        no
        not_sure
      ]
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
