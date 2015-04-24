module SmartdownPlugins
  module HelpIfYouAreArrestedAbroadTransition
    def self.world_locations
      excluded_countries = %w(holy-see british-antarctic-territory)

      country_select = SmartAnswer::Question::CountrySelect.new('help-if-you-are-arrested-abroad', exclude_countries: excluded_countries)

      country_select.country_list.reduce({}) do |countries, country|
        countries[country.slug] = country.title
        countries
      end
    end
  end
end
