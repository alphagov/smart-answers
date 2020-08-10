module CoronavirusFindSupport
  class NeedHelpWithForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :need_help_with

    def options
      {
        feeling_unsafe: "Feeling unsafe where you live, or being worried about someone else",
        paying_bills: "Paying bills",
        getting_food: "Getting food",
        being_unemployed: "Being unemployed or not having any work",
        going_to_work: "Going in to work",
        somewhere_to_live: "Having somewhere to live",
        mental_health: "Mental health and wellbeing",
        not_sure: "I'm not sure",
      }.each_with_object([]) do |(key, value), array|
        array << { label: value, value: key.to_s }
      end
    end

    def initialize; end
  end
end
