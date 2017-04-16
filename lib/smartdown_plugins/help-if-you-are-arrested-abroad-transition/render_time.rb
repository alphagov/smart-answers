module SmartdownPlugins
  module HelpIfYouAreArrestedAbroadTransition


    def self.transfers_back_to_uk_treaty_change_countries?(country)
      %w(austria belgium croatia denmark finland hungary italy latvia luxembourg malta netherlands slovakia).exclude?(country.value)
    end

    def self.region_links(country_of_arrest)
      arrested_calc = SmartAnswer::Calculators::ArrestedAbroadSmartdown.new
      links = []
      if arrested_calc.countries_with_regions.include?(country_of_arrest.value)
        regions = arrested_calc.get_country_regions(country_of_arrest.value)
        regions.each do |key, val|
          links << "- [#{val['url_text']}](#{val['link']})"
        end
      end
      links.join("\n")
    end

    def self.doc(country_of_arrest)
      arrested_calc = SmartAnswer::Calculators::ArrestedAbroadSmartdown.new
      arrested_calc.generate_url_for_download(country_of_arrest.value, "doc", "prisoner pack for #{country_of_arrest}")
    end

    def self.pdf(country_of_arrest)
      arrested_calc = SmartAnswer::Calculators::ArrestedAbroadSmartdown.new
      arrested_calc.generate_url_for_download(country_of_arrest.value, "pdf", "prisoner pack for #{country_of_arrest}")
    end

    def self.benefits(country_of_arrest)
      arrested_calc = SmartAnswer::Calculators::ArrestedAbroadSmartdown.new
      arrested_calc.generate_url_for_download(country_of_arrest.value, "benefits", "benefits or legal aid in #{country_of_arrest}")
    end

    def self.prison(country_of_arrest)
      arrested_calc = SmartAnswer::Calculators::ArrestedAbroadSmartdown.new
      arrested_calc.generate_url_for_download(country_of_arrest.value, "prison", "information on prisons and prison procedures in #{country_of_arrest}")
    end

    def self.judicial(country_of_arrest)
      arrested_calc = SmartAnswer::Calculators::ArrestedAbroadSmartdown.new
      arrested_calc.generate_url_for_download(country_of_arrest.value, "judicial", "information on the judicial system and procedures in #{country_of_arrest}")
    end

    def self.police(country_of_arrest)
      arrested_calc = SmartAnswer::Calculators::ArrestedAbroadSmartdown.new
      arrested_calc.generate_url_for_download(country_of_arrest.value, "police", "information on the police and police procedures in #{country_of_arrest}")
    end

    def self.consul(country_of_arrest)
      arrested_calc = SmartAnswer::Calculators::ArrestedAbroadSmartdown.new
      arrested_calc.generate_url_for_download(country_of_arrest.value, "consul", "consul help available in #{country_of_arrest}")
    end

    def self.lawyer(country_of_arrest)
      arrested_calc = SmartAnswer::Calculators::ArrestedAbroadSmartdown.new
      arrested_calc.generate_url_for_download(country_of_arrest.value, "lawyer", "english speaking lawyers and translators/interpreters in #{country_of_arrest}")
    end

  end
end
