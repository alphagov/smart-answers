module SmartAnswer::Calculators
  class MarriageAbroadDataQueryV2

    COMMONWEALTH_COUNTRIES = %w(antigua-and-barbuda australia bahamas bangladesh barbados belize botswana brunei cameroon canada cyprus dominica fiji gambia ghana grenada guyana india jamaica kenya kiribati lesotho malawi malaysia maldives malta mauritius mozambique namibia nauru new-zealand nigeria pakistan papua-new-guinea st-kitts-and-nevis st-lucia st-vincent-and-the-grenadines samoa seychelles sierra-leone singapore solomon-islands south-africa sri-lanka swaziland tanzania tonga trinidad-and-tobago tuvalu uganda vanuatu zambia)

    BRITISH_OVERSEAS_TERRITORIES = %w(anguilla bermuda british-antarctic-territory british-indian-ocean-territory british-virgin-islands cayman-islands falkland-islands gibraltar montserrat pitcairn-island st-helena-ascension-and-tristan-da-cunha south-georgia-and-south-sandwich-islands turks-and-caicos-islands)

    FRENCH_OVERSEAS_TERRITORIES = %w(french-guiana french-polynesia guadeloupe martinique mayotte new-caledonia reunion st-pierre-and-miquelon wallis-and-futuna)

    DUTCH_CARIBBEAN_ISLANDS = %w(aruba bonaire-st-eustatius-saba curacao st-maarten)

    NON_COMMONWEALTH_COUNTRIES = %w(afghanistan albania algeria american-samoa andorra angola anguilla argentina armenia aruba austria azerbaijan bahrain belarus belgium benin bermuda bhutan bolivia bonaire-st-eustatius-saba bosnia-and-herzegovina brazil british-indian-ocean-territory british-virgin-islands bulgaria burkina-faso burma burundi cambodia cape-verde cayman-islands central-african-republic chad chile china colombia comoros congo democratic-republic-of-congo costa-rica cote-d-ivoire croatia cuba curacao czech-republic denmark djibouti dominican-republic ecuador egypt el-salvador equatorial-guinea eritrea estonia ethiopia falkland-islands fiji finland france french-guiana french-polynesia gabon georgia germany gibraltar greece guadeloupe guatemala guinea guinea-bissau haiti honduras hong-kong hungary iceland indonesia iran iraq ireland israel italy japan jordan kazakhstan south-korea kosovo kuwait kyrgyzstan laos latvia lebanon liberia libya liechtenstein lithuania luxembourg macao macedonia madagascar mali marshall-islands martinique mauritania mayotte mexico micronesia moldova monaco mongolia montenegro montserrat morocco nepal netherlands new-caledonia nicaragua niger north-korea norway oman palau panama paraguay peru philippines pitcairn-island poland portugal qatar reunion romania russia rwanda san-marino sao-tome-and-principe saudi-arabia senegal serbia slovakia slovenia somalia south-georgia-and-south-sandwich-islands south-sudan spain st-helena-ascension-and-tristan-da-cunha st-maarten st-pierre-and-miquelon sudan suriname sweden switzerland syria taiwan tajikistan thailand timor-leste togo tunisia turkmenistan turks-and-caicos-islands ukraine united-arab-emirates usa uruguay uzbekistan venezuela wallis-and-futuna western-sahara vietnam yemen zimbabwe)

    OS_CONSULAR_CNI_COUNTRIES = %w(albania algeria angola armenia austria azerbaijan bahrain belarus belgium bolivia bosnia-and-herzegovina brazil bulgaria cambodia chile colombia croatia cuba denmark dominican-republic ecuador el-salvador estonia ethiopia georgia germany greece guatemala honduras hungary iceland indonesia italy japan jordan kazakhstan kuwait kyrgyzstan latvia libya lithuania luxembourg macedonia moldova montenegro netherlands nepal norway oman panama poland romania russia serbia slovenia spain sudan sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)

    OS_NO_CONSULAR_CNI_COUNTRIES = %w(argentina burundi czech-republic democratic-republic-of-congo mexico senegal slovakia taiwan usa uruguay)

    OS_NO_MARRIAGE_CONSULAR_SERVICES = %w(afghanistan american-samoa andorra aruba benin bhutan bonaire-st-eustatius-saba burkina-faso burundi cape-verde central-african-republic chad comoros congo costa-rica cote-d-ivoire curacao djibouti equatorial-guinea eritrea gabon guinea guinea-bissau haiti hong-kong iraq israel kosovo laos liberia liechtenstein macao madagascar mali marshall-islands mauritania micronesia monaco nicaragua niger palau paraguay rwanda san-marino sao-tome-and-principe south-sudan st-maarten suriname timor-leste togo western-sahara)

    OS_OTHER_COUNTRIES = %w(burma north-korea iran somalia syria yemen saudi-arabia)

    OS_AFFIRMATION_COUNTRIES = %w(china egypt lebanon finland mongolia morocco peru philippines portugal qatar south-korea thailand turkey united-arab-emirates vietnam)

    CP_EQUIVALENT_COUNTRIES = %w(austria belgium brazil colombia czech-republic denmark ecuador finland germany hungary iceland luxembourg netherlands norway portugal slovenia sweden)

    CP_CNI_NOT_REQUIRED_COUNTRIES = %w(argentina mexico uruguay usa andorra bonaire-st-eustatius-saba liechtenstein burundi )

    CP_CONSULAR_COUNTRIES = %w(bulgaria cambodia costa-rica croatia cyprus guatemala japan latvia moldova panama peru philippines turkmenistan venezuela vietnam)

    COUNTRIES_WITHOUT_CONSULAR_FACILITIES = %w(aruba slovakia curacao bonaire-st-eustatius-saba st-maarten taiwan czech-republic argentina cote-d-ivoire burundi)

    SS_MARRIAGE_COUNTRIES = %w(australia azerbaijan bolivia chile china colombia dominican-republic estonia kosovo latvia mongolia montenegro nicaragua russia san-marino hungary serbia)

    SS_MARRIAGE_COUNTRIES_WHEN_COUPLE_BRITISH = %w(lithuania)

    SS_MARRIAGE_AND_PARTNERSHIP_COUNTRIES = %w(cambodia costa-rica peru philippines vietnam japan)

    SS_CLICKBOOK_COUNTRIES = %w(bolivia chile china colombia costa-rica hungary mongolia montenegro peru philippines russia san-marino serbia vietnam)

    SS_ALT_FEES_TABLE_COUNTRY = %w(australia bolivia china estonia san-marino serbia)

    SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_A = %w(hungary mongolia montenegro nicaragua russia)

    SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_B = %w(azerbaijan chile dominican-republic kosovo latvia)

    def ss_clickbook_countries?(country_slug)
      SS_CLICKBOOK_COUNTRIES.include?(country_slug)
    end

    def ss_marriage_countries?(country_slug)
      SS_MARRIAGE_COUNTRIES.include?(country_slug)
    end

    def ss_marriage_countries_when_couple_british?(country_slug)
      SS_MARRIAGE_COUNTRIES_WHEN_COUPLE_BRITISH.include?(country_slug)
    end

    def ss_marriage_and_partnership?(country_slug)
      SS_MARRIAGE_AND_PARTNERSHIP_COUNTRIES.include?(country_slug)
    end

    def ss_alt_fees_table_country?(country_slug, partner_nationality)
      SS_ALT_FEES_TABLE_COUNTRY.include?(country_slug) ||
        (SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_A.include?(country_slug) && partner_nationality == "partner_british") ||
        (SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_B.include?(country_slug) && partner_nationality != "partner_local") &&
        (%w(cambodia vietnam).exclude?(country_slug))
    end

    def ss_marriage_not_possible?(country_slug, partner_nationality)
      (SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_A.include?(country_slug) && partner_nationality != "partner_british") ||
        ((SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_B.include?(country_slug) || %w(cambodia vietnam).include?(country_slug)) && partner_nationality == "partner_local")
    end

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

    def cp_consular_countries?(country_slug)
      CP_CONSULAR_COUNTRIES.include?(country_slug)
    end

    def os_affirmation_countries?(country_slug)
      OS_AFFIRMATION_COUNTRIES.include?(country_slug)
    end

    def countries_without_consular_facilities?(country_slug)
      COUNTRIES_WITHOUT_CONSULAR_FACILITIES.include?(country_slug)
    end
  end
end
