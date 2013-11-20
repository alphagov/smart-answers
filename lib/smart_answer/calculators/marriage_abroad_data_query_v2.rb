module SmartAnswer::Calculators
  class MarriageAbroadDataQueryV2

    COMMONWEALTH_COUNTRIES = %w(antigua-and-barbuda australia bahamas bangladesh barbados belize botswana brunei cameroon canada cyprus dominica fiji gambia ghana grenada guyana india jamaica kenya kiribati lesotho malawi malaysia maldives malta mauritius mozambique namibia nauru new-zealand nigeria pakistan papua-new-guinea st-kitts-and-nevis st-lucia st-vincent-and-the-grenadines samoa seychelles sierra-leone singapore solomon-islands south-africa sri-lanka swaziland tanzania tonga trinidad-and-tobago tuvalu uganda vanuatu zambia)

    BRITISH_OVERSEAS_TERRITORIES = %w(anguilla bermuda british-antarctic-territory british-indian-ocean-territory british-virgin-islands cayman-islands falkland-islands gibraltar montserrat pitcairn-island st-helena-ascension-and-tristan-da-cunha south-georgia-and-south-sandwich-islands turks-and-caicos-islands)

    FRENCH_OVERSEAS_TERRITORIES = %w(french-guiana french-polynesia guadeloupe martinique mayotte new-caledonia reunion st-pierre-and-miquelon wallis-and-futuna)

    DUTCH_CARIBBEAN_ISLANDS = %w(aruba bonaire-st-eustatius-saba curacao st-maarten)

    NON_COMMONWEALTH_COUNTRIES = %w(afghanistan albania algeria american-samoa andorra angola anguilla argentina armenia aruba austria azerbaijan bahrain belarus belgium benin bermuda bhutan bolivia bonaire-st-eustatius-saba bosnia-and-herzegovina brazil british-indian-ocean-territory british-virgin-islands bulgaria burkina-faso burma burundi cambodia cape-verde cayman-islands central-african-republic chad chile china colombia comoros congo democratic-republic-of-congo costa-rica cote-d-ivoire croatia cuba curacao czech-republic denmark djibouti dominican-republic ecuador egypt el-salvador equatorial-guinea eritrea estonia ethiopia falkland-islands fiji finland france french-guiana french-polynesia gabon georgia germany gibraltar greece guadeloupe guatemala guinea guinea-bissau haiti honduras hong-kong hungary iceland indonesia iran iraq ireland israel italy japan jordan kazakhstan south-korea kosovo kuwait kyrgyzstan laos latvia lebanon liberia libya liechtenstein lithuania luxembourg macao macedonia madagascar mali marshall-islands martinique mauritania mayotte mexico micronesia moldova monaco mongolia montenegro montserrat morocco nepal netherlands new-caledonia nicaragua niger north-korea norway oman palau panama paraguay peru philippines pitcairn-island poland portugal qatar reunion romania russia rwanda san-marino sao-tome-and-principe saudi-arabia senegal serbia slovakia slovenia somalia south-georgia-and-south-sandwich-islands south-sudan spain st-helena-ascension-and-tristan-da-cunha st-maarten st-pierre-and-miquelon sudan suriname sweden switzerland syria taiwan tajikistan thailand timor-leste togo tunisia turkey turkmenistan turks-and-caicos-islands ukraine united-arab-emirates usa uruguay uzbekistan venezuela vietnam wallis-and-futuna western-sahara yemen zimbabwe)

    OS_CONSULAR_CNI_COUNTRIES = %w(albania algeria angola argentina armenia austria azerbaijan bahrain belarus belgium bolivia bosnia-and-herzegovina brazil bulgaria cambodia chile china colombia croatia cuba czech-republic denmark dominican-republic ecuador el-salvador estonia ethiopia finland georgia germany greece guatemala honduras hungary iceland indonesia italy japan jordan kazakhstan kuwait kyrgyzstan latvia libya lithuania luxembourg macedonia moldova mongolia montenegro netherlands nepal norway oman panama peru philippines poland portugal qatar romania russia serbia slovakia slovenia spain sudan sweden switzerland tajikistan tunisia turkey turkmenistan ukraine uzbekistan venezuela vietnam)

    OS_NO_CONSULAR_CNI_COUNTRIES = %w(democratic-republic-of-congo mexico senegal taiwan usa uruguay)

    OS_NO_MARRIAGE_CONSULAR_SERVICES = %w(afghanistan american-samoa andorra aruba benin bhutan bonaire-st-eustatius-saba burkina-faso burundi cape-verde central-african-republic chad comoros congo costa-rica cote-d-ivoire curacao djibouti equatorial-guinea eritrea gabon guinea guinea-bissau haiti hong-kong iraq israel kosovo laos liberia liechtenstein macao madagascar mali marshall-islands mauritania micronesia monaco morocco nicaragua niger palau paraguay rwanda san-marino sao-tome-and-principe south-sudan st-maarten suriname timor-leste togo western-sahara)

    OS_OTHER_COUNTRIES = %w(burma north-korea iran somalia syria yemen saudi-arabia)

    CP_EQUIVALENT_COUNTRIES = %w(argentina austria belgium brazil colombia denmark ecuador finland germany hungary iceland luxembourg netherlands norway portugal slovenia sweden switzerland)

    CP_CNI_NOT_REQUIRED_COUNTRIES = %w(mexico uruguay usa andorra bonaire-st-eustatius-saba liechtenstein)

    CP_CONSULAR_CNI_COUNTRIES = %w(bulgaria cambodia costa-rica croatia cyprus guatemala japan latvia moldova mongolia panama peru philippines turkmenistan venezuela vietnam)

    COUNTRIES_WITH_DEFINITIVE_ARTICLES = %w(bahamas british-virgin-islands cayman-islands czech-republic democratic-republic-of-congo dominican-republic falkland-islands gambia maldives marshall-islands netherlands philippines seychelles solomon-islands south-georgia-and-south-sandwich-islands turks-and-caicos-islands united-arab-emirates)

    COUNTRY_NAME_TRANSFORM = { 
      "democratic-republic-of-congo" => "Democratic Republic of Congo",
      "cote-d-ivoire" => "Cote d'Ivoire",
      "pitcairn" => "Pitcairn Island",
      "south-korea" => "South Korea",
      "st-helena-ascension-and-tristan-da-cunha" => "St Helena, Ascension and Tristan da Cunha", 
      "usa" => "the USA"
    }

    def commonwealth_country?(country_slug)
      COMMONWEALTH_COUNTRIES.include?(country_slug)
    end

    def british_overseas_territories?(country_slug)
      BRITISH_OVERSEAS_TERRITORIES.include?(country_slug)
    end

    def non_commonwealth_country?(country_slug)
      NON_COMMONWEALTH_COUNTRIES.include?(country_slug)
    end

    def french_overseas_territories?(country_slug)
      FRENCH_OVERSEAS_TERRITORIES.include?(country_slug)
    end

    def dutch_caribbean_islands?(country_slug)
      DUTCH_CARIBBEAN_ISLANDS.include?(country_slug)
    end

    def os_consular_cni_countries?(country_slug)
      OS_CONSULAR_CNI_COUNTRIES.include?(country_slug)
    end

    def os_no_consular_cni_countries?(country_slug)
      OS_NO_CONSULAR_CNI_COUNTRIES.include?(country_slug)
    end

    def os_no_marriage_related_consular_services?(country_slug)
      OS_NO_MARRIAGE_CONSULAR_SERVICES.include?(country_slug)
    end

    def os_other_countries?(country_slug)
      OS_OTHER_COUNTRIES.include?(country_slug)
    end

    def cp_equivalent_countries?(country_slug)
      CP_EQUIVALENT_COUNTRIES.include?(country_slug)
    end

    def cp_cni_not_required_countries?(country_slug)
      CP_CNI_NOT_REQUIRED_COUNTRIES.include?(country_slug)
    end

    def cp_consular_cni_countries?(country_slug)
      CP_CONSULAR_CNI_COUNTRIES.include?(country_slug)
    end

    def countries_with_definitive_articles?(country_slug)
      COUNTRIES_WITH_DEFINITIVE_ARTICLES.include?(country_slug)
    end

  end
end
