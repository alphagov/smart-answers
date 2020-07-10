module SmartAnswer::Calculators
  class ArrestedAbroad
    # created for the help-if-you-are-arrested-abroad calculator
    attr_reader :data

    PRISONER_PACKS = YAML.load_file(Rails.root.join("config/smart_answers/prisoner_packs.yml")).freeze

    def generate_url_for_download(country, field, text)
      country_data = PRISONER_PACKS.find { |c| c["slug"] == country }
      return "" unless country_data

      url = country_data[field]
      output = []
      if url
        urls = url.split(" ")
        urls.each do |u|
          new_link = "- [#{text}](#{u})"
          new_link += '{:rel="external"}' if u.include? "http"
          output.push(new_link)
        end
        output.join("\n")
      else
        ""
      end
    end

    def countries_with_regions
      %w[cyprus]
    end

    def get_country_regions(slug)
      PRISONER_PACKS.find { |c| c["slug"] == slug }["regions"]
    end
  end
end
