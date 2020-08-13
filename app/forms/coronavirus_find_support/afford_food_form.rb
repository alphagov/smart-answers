module CoronavirusFindSupport
  class AffordFoodForm < Form
    answer_flow :coronavirus_find_support
    answer_node :afford_food

    validates :afford_food, presence: { message: t("errors.blank") }

    def options
      %i[yes no not_sure]
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
