module CoronavirusFindSupport
  class GetFoodForm < Form
    attr_accessor :get_food

    validates :get_food, presence: { message: "Select yes if you’re able to get food" }

    def options
      {
        yes: "Yes",
        no: "No",
        not_sure: "Not sure",
      }
    end
  end
end
