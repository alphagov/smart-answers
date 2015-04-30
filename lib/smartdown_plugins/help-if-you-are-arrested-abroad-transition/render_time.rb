module SmartdownPlugins
  module HelpIfYouAreArrestedAbroadTransition
    def self.transfers_back_to_uk_treaty_change_countries?(country)
      %w(austria belgium croatia denmark finland hungary italy latvia luxembourg malta netherlands slovakia).exclude?(country.value)
    end
  end
end
