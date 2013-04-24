module SmartAnswer::Calculators
  class ArrestedAbroad
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
          new_link += '{:rel="external"}' if u.include? "http"
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

    def countries_no_pack
      %w{ afghanistan algeria american-samoa andorra angola anguilla aruba ascension-island bahamas benin bermuda bhutan bonaire-st-eustatius-saba bosnia-and-herzegovina british-antarctic-territory british-indian-ocean-territory british-virgin-islands burkina-faso burundi cape-verde cayman-islands central-african-republic chad comoros congo congo-(democratic-republic) cote-d_ivoire-(ivory-coast) curacao djibouti equatorial-guinea eritrea falkland-islands fiji french-guiana french-polynesia gabon gambia gibraltar guadeloupe guinea guinea-bissau haiti honduras iraq kazakhstan kenya kiribati kyrgyzstan kosovo laos lesotho liberia liechtenstein macao madagascar maldives mali malta marshall-islands martinique mauritania mayotte micronesia monaco mongolia montenegro nauru new-caledonia nicaragua niger nigeria north-korea oman palau papua-new-guinea pitcairn reunion samoa san-marino sao-tome-and-principe senegal somalia south-georgia-and-south-sandwich-islands south-sudan st-helena st-maarten st-pierre-and-miquelon sudan swaziland syria togo tonga tristan-da-cunha turkmenistan turks-and-caicos-islands tuvalu vanuatu wallis-and-futuna western-sahara }
    end

    def countries_with_regions
      %w{ australia united-arab-emirates cyprus }
    end

    def get_country_regions(slug)
      @data.select { |c| c["slug"] == slug }.first["regions"]
    end
  end
end
