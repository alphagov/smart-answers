module SmartAnswer::Calculators
  class ArrestedAbroad
    # created for the help-if-you-are-arrested-abroad calculator
    attr_reader :data

    def initialize
      @data = self.class.prisoner_packs
    end

    def no_prisoner_packs
      %w()
    end

    def generate_url_for_download(country, field, text)
      url = @data.select { |c| c["slug"] == country }.first[field]
      output = []
      if url
        urls = url.split(" ")
        urls.each do |u|
          output.push("- [#{text}](#{u}){:rel=\"external\"}")
        end
        output.join("\n")
      else
        ""
      end
    end

    def self.prisoner_packs
      @prisoner_packs ||= YAML::load_file(Rails.root.join("lib", "data", "prisoner_packs.yml"))
    end


  end
end
