module SmartAnswer
  class LoggedError < BaseStateTransitionError
    def initialize(message = nil, log_message = nil)
      super(message)
      @log_message = log_message
    end

    # Airbrake#notify requires an Error as an argument, so instead
    # of returning the message string, wrap it in an error
    def log_exception
      LoggedError.new(@log_message)
    end
  end
end
