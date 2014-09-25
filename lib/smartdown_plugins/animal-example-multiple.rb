module SmartdownPlugins
  module AnimalExampleMultiple
    def self.years_until_training_forgotten(training_date)
      (Date.parse(training_date).year + 20) - Time.zone.now.year
    end
  end
end
