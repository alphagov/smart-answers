module CoronavirusFindSupport
  class AffordFoodForm < Form
    attr_accessor :afford_food

    validates :afford_food, presence: { message: "Select yes if you’re finding it hard to afford food" }

    def options
      {
        yes: "Yes",
        no: "No",
        not_sure: "Not sure",
      }
    end
  end
end
