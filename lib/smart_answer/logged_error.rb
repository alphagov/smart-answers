module SmartAnswer
  class LoggedError < BaseStateTransitionError
    def initialize(message = nil, log_message = nil)
      super(message)
      @log_message = log_message
    end
  end
end
