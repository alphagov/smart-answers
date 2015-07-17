module SmartAnswer
  module OverseasPassportsHelper
    def timing_prefix(optimistic_processing_time)
      if optimistic_processing_time
        "should take"
      else
        "will take **at least**"
      end
    end
  end
end
