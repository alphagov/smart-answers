module SmartdownAdapter
  module Plugins
    class YearsUntilTrainingForgotten
      def self.key
        "years_until_training_forgotten"
      end

      def call(training_date)
        (Date.parse(training_date).year + 20) - Time.zone.now.year
      end
    end
  end
end
