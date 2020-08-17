module CoronavirusFindSupport
  class GetFoodForm < Form
    answer_flow :coronavirus_find_support
    answer_node :get_food

    validates :get_food, presence: { message: t("errors.blank") }

    def options
      %i[yes no not_sure]
    end
  end
end
