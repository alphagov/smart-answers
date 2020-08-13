module CoronavirusFindSupport
  class HaveSomewhereToLiveForm < Form
    answer_flow :coronavirus_find_support
    answer_node :have_somewhere_to_live

    validates :have_somewhere_to_live, presence: { message: t("errors.blank") }

    def options
      %i[yes yes_but_i_might_lose_it no not_sure]
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
