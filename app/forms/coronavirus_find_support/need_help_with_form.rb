module CoronavirusFindSupport
  class NeedHelpWithForm < Form
    answer_flow :coronavirus_find_support
    answer_node :need_help_with

    validates :need_help_with,
              presence: { message: t("errors.blank") },
              valid_options: { message: t("errors.valid_options") }

    def options
      %i[
        feeling_unsafe
        paying_bills
        getting_food
        being_unemployed
        going_to_work
        somewhere_to_live
        mental_health
        not_sure
      ]
    end
  end
end
