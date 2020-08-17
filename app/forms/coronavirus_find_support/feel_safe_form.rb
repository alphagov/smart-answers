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
  end
end
