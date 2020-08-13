module CoronavirusFindSupport
  class NationForm < Form
    answer_flow :coronavirus_find_support
    answer_node :nation

    validates :nation,
              presence: { message: t("errors.blank") },
              valid_options: { message: t("errors.valid_options") }

    def options
      %i[england scotland wales northern_ireland]
    end
  end
end
