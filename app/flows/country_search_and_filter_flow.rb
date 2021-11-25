class CountrySearchAndFilterFlow < SmartAnswer::Flow
  def define
    name "country-search-and-filter"
    content_id "cb3d7d6a-0140-4706-8583-bafecdf06f53"
    status :draft

    checkbox_question :countries do
      self.select_filter = true

      SmartAnswer::Calculators::CountrySearchAndFilterCalculator.countries.each_key do |slug|
        option slug.to_sym
      end

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::CountrySearchAndFilterCalculator.new
        calculator.countries = response
      end

      next_node do
        outcome :results
      end
    end

    outcome :results
  end
end
