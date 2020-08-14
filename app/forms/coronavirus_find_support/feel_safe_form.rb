module CoronavirusFindSupport
  class FeelSafeForm < Form
    attr_accessor :feel_safe

    validates :feel_safe,
              presence: { message: "Select if you feel safe where you live or if you’re worried about someone else" }

    def options
      {
        yes: "Yes",
        yes_but_i_am_concerned_about_others: "Yes, but I’m worried about the safety of another adult or a child",
        no: "No",
        not_sure: "Not sure",
      }
    end
  end
end
