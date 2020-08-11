module CoronavirusFindSupport
  class FeelSafeForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :session, :feel_safe
    attr_reader :params

    def initialize(params, session)
      @params = params
      @session = session
    end

    def options
      {
        yes: "Yes",
        no: "No",
        not_sure: "Not sure",
      }.each_with_object([]) do |(key, value), array|
        array << { label: value, value: key.to_s }
      end
    end
  end
end
