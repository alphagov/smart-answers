module SmartAnswer::Calculators
  class ArrestedAbroadSmartdown
    # created for the help-if-you-are-arrested-abroad calculator
    attr_reader :data

    def initialize
      @data = self.class.prisoner_packs
    end

    def generate_url_for_download(country, field, text)
      country_data = @data.select { |c| c["slug"] == country }.first
      return "" unless country_data

      url = country_data[field]
      output = []
      if url
        urls = url.split(" ")
        urls.each do |u|
          new_link = "- [#{text}](#{u})"
          output.push(new_link)
        end
        output.join("\n")
      else
        ""
      end
    end

    def self.prisoner_packs
      @prisoner_packs ||= YAML::load_file(Rails.root.join("lib", "data", "prisoner_packs.yml"))
    end

    def countries_with_regions
      %w{ cyprus }
    end

    def get_country_regions(slug)
      @data.select { |c| c["slug"] == slug }.first["regions"]
    end
  end
end
