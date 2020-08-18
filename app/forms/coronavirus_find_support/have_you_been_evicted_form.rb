module CoronavirusFindSupport
  class HaveYouBeenEvictedForm < Form
    answer_flow :coronavirus_find_support
    answer_node :have_you_been_evicted

    validates :have_you_been_evicted, presence: { message: t("errors.blank") }

    def options
      %i[yes yes_i_might_be_soon no not_sure]
    end

    def prepare_session
      session[flow_name] ||= {}
      session[flow_name]["somewhere_to_live"] ||= {}
    end

    def update_session
      session[flow_name]["somewhere_to_live"][node_name] = data_to_be_stored_in_session
    end
  end
end
