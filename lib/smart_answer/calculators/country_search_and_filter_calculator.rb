module SmartAnswer::Calculators
  class CountrySearchAndFilterCalculator
    attr_accessor :countries

    def self.countries
      countries = {}
      WorldLocation.all.each do |country|
        countries[country.slug] = country.title
      end
      countries
    end
  end
end
