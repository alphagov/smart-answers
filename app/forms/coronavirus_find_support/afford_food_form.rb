module CoronavirusFindSupport
  class AffordFoodForm < Form
    answer_flow :coronavirus_find_support
    answer_node :afford_food

    validates :afford_food, presence: { message: t("errors.blank") }

    def options
      %i[yes no not_sure]
    end
  end
end
