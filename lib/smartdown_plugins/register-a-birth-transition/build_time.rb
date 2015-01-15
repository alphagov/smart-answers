module SmartdownPlugins
  module RegisterABirthTransition

    EXCLUDED_COUNTRIES = %w(holy-see british-antarctic-territory)

    def self.world_locations
      country_select = SmartAnswer::Question::CountrySelect.new(
        'register-a-birth',
        :exclude_countries => EXCLUDED_COUNTRIES)

      country_hash = {}
      country_select.country_list.map do |country|
        country_hash[country.slug] = country.title
      end
      country_hash
    end

  end
end
