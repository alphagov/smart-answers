module SmartdownPlugins
  module AnimalExampleMultiple
    def self.years_until_training_forgotten(training_date)
      training_date.value.year + 20 - Time.zone.now.year
    end
  end
end
