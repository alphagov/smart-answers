module SmartAnswer
  module Helpers::QuestionOptionsHelper
    def options(options = nil)
      if options
        @options = options
      else
        @options || {}
      end
    end
  end
end
