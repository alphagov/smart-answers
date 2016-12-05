module SmartAnswer::Calculators
  class MarriageAbroadDataQuery
    COMMONWEALTH_COUNTRIES = %w(antigua-and-barbuda australia bahamas bangladesh barbados belize botswana brunei cameroon canada cyprus dominica fiji gambia ghana grenada guyana india jamaica kenya kiribati lesotho malawi malaysia maldives malta mauritius namibia nauru new-zealand nigeria pakistan papua-new-guinea samoa seychelles sierra-leone singapore solomon-islands south-africa sri-lanka st-kitts-and-nevis st-lucia st-vincent-and-the-grenadines  swaziland tanzania tonga trinidad-and-tobago tuvalu uganda vanuatu zambia)

    REQUIRES_7_DAY_NOTICE_CEREMONY_COUNTRIES = (COMMONWEALTH_COUNTRIES - %w(brunei gambia)) + %w(ireland rwanda st-lucia)

    BRITISH_OVERSEAS_TERRITORIES = %w(anguilla bermuda british-antarctic-territory british-indian-ocean-territory british-virgin-islands cayman-islands falkland-islands gibraltar montserrat pitcairn-island st-helena-ascension-and-tristan-da-cunha south-georgia-and-south-sandwich-islands turks-and-caicos-islands)

    FRENCH_OVERSEAS_TERRITORIES = %w(french-guiana french-polynesia guadeloupe martinique mayotte new-caledonia reunion st-pierre-and-miquelon wallis-and-futuna)

    FRENCH_OVERSEAS_TERRITORIES_OFFERING_PACS = %w(new-caledonia wallis-and-futuna)

    CEREMONY_COUNTRIES_OFFERING_PACS = %w(france monaco) + FRENCH_OVERSEAS_TERRITORIES_OFFERING_PACS

    DUTCH_CARIBBEAN_ISLANDS = %w(aruba bonaire-st-eustatius-saba curacao st-maarten)

    OS_CONSULAR_CNI_COUNTRIES = %w(albania algeria angola armenia austria azerbaijan bahrain belarus bolivia bosnia-and-herzegovina brazil bulgaria chile croatia cuba democratic-republic-of-the-congo denmark dominican-republic el-salvador estonia ethiopia georgia germany greece guatemala honduras hungary iceland japan jordan kazakhstan kuwait kyrgyzstan latvia libya lithuania luxembourg macedonia mexico moldova montenegro netherlands nepal oman panama poland romania russia serbia slovenia spain sudan tajikistan tunisia turkmenistan uzbekistan venezuela)

    OS_NO_CONSULAR_CNI_COUNTRIES = %w(burundi democratic-republic-of-the-congo mexico saint-barthelemy st-martin)

    OS_MARRIAGE_VIA_LOCAL_AUTHORITIES = %w(argentina costa-rica cote-d-ivoire czech-republic israel liberia madagascar netherlands paraguay senegal taiwan ukraine uruguay usa)

    OS_NO_MARRIAGE_CONSULAR_SERVICES = %w(afghanistan american-samoa andorra aruba benin bhutan bonaire-st-eustatius-saba burkina-faso burundi cape-verde central-african-republic chad comoros congo curacao djibouti equatorial-guinea eritrea gabon guinea guinea-bissau haiti hong-kong iraq kosovo laos liechtenstein mali marshall-islands mauritania micronesia monaco nicaragua niger palau paraguay rwanda san-marino sao-tome-and-principe south-sudan st-maarten suriname timor-leste togo western-sahara)

    OS_CONSULAR_CNI_IN_NEARBY_COUNTRY = %w(nicaragua)

    OS_AFFIRMATION_COUNTRIES = %w(belgium cambodia colombia china ecuador egypt lebanon finland macao mongolia morocco norway peru philippines qatar south-korea thailand turkey united-arab-emirates vietnam)

    CP_EQUIVALENT_COUNTRIES = %w(austria brazil colombia czech-republic denmark ecuador finland germany hungary iceland luxembourg netherlands norway portugal slovenia)

    CP_CNI_NOT_REQUIRED_COUNTRIES = %w(andorra argentina bonaire-st-eustatius-saba burundi liechtenstein mexico new-zealand uruguay usa)

    CP_CONSULAR_COUNTRIES = %w(bulgaria croatia cyprus guatemala moldova panama venezuela)

    COUNTRIES_WITHOUT_CONSULAR_FACILITIES = %w(argentina aruba bonaire-st-eustatius-saba burundi cote-d-ivoire curacao czech-republic saint-barthelemy slovakia st-maarten st-martin taiwan)

    SS_MARRIAGE_COUNTRIES = %w(australia bolivia chile china colombia dominican-republic estonia germany hungary kosovo latvia mongolia montenegro nicaragua russia san-marino serbia)

    NO_SS_MARRIAGE_COUNTRIES = %w(san-marino seychelles)

    SS_MARRIAGE_COUNTRIES_WHEN_COUPLE_BRITISH = %w(lithuania)

    SS_MARRIAGE_AND_PARTNERSHIP_COUNTRIES = %w(albania cambodia japan peru philippines vietnam)

    SS_ALT_FEES_TABLE_COUNTRY = %w(australia bolivia china estonia san-marino serbia seychelles)

    SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_A = %w(hungary mongolia montenegro nicaragua russia)

    SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_B = %w(azerbaijan chile dominican-republic kosovo latvia)

    OS_21_DAYS_RESIDENCY_REQUIRED_COUNTRIES = %w(jordan oman qatar yemen)

    SS_UNKNOWN_NO_EMBASSIES = %w(st-martin saint-barthelemy)

    THREE_DAY_RESIDENCY_REQUIREMENT_COUNTRIES = %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria chile croatia cuba democratic-republic-of-the-congo denmark dominican-republic el-salvador estonia ethiopia georgia greece guatemala honduras hungary iceland kazakhstan kosovo kuwait kyrgyzstan latvia lithuania luxembourg macedonia mexico moldova montenegro nepal panama romania russia serbia slovenia sudan tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)

    CNI_NOTARY_PUBLIC_COUNTRIES = %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria croatia cuba estonia georgia greece iceland kazakhstan kuwait kyrgyzstan libya lithuania luxembourg mexico moldova montenegro russia serbia tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)

    NO_DOCUMENT_DOWNLOAD_LINK_IF_OS_RESIDENT_OF_UK_COUNTRIES = %w(albania algeria angola armenia austria azerbaijan bahrain bolivia bosnia-and-herzegovina bulgaria croatia cuba estonia georgia greece iceland japan kazakhstan kuwait kyrgyzstan libya lithuania luxembourg macedonia mexico moldova montenegro nicaragua russia serbia tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)

    CNI_POSTED_AFTER_14_DAYS_COUNTRIES = %w(jordan qatar saudi-arabia united-arab-emirates yemen)

    def os_21_days_residency_required_countries?(country_slug)
      OS_21_DAYS_RESIDENCY_REQUIRED_COUNTRIES.include?(country_slug)
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

    def ss_alt_fees_table_country?(country_slug, calculator)
      SS_ALT_FEES_TABLE_COUNTRY.include?(country_slug) ||
        (SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_A.include?(country_slug) && calculator.partner_british?) ||
        (SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_B.include?(country_slug) && calculator.partner_is_not_national_of_ceremony_country?) &&
          (%w(cambodia vietnam).exclude?(country_slug))
    end

    def ss_marriage_not_possible?(country_slug, calculator)
      (SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_A.include?(country_slug) && calculator.partner_not_british?) ||
        ((SS_ALT_FEES_TABLE_OR_OUTCOME_GROUP_B.include?(country_slug) || %w(cambodia vietnam).include?(country_slug)) && calculator.partner_is_national_of_ceremony_country?) ||
        NO_SS_MARRIAGE_COUNTRIES.include?(country_slug)
    end

    def commonwealth_country?(country_slug)
      COMMONWEALTH_COUNTRIES.include?(country_slug)
    end

    def british_overseas_territories?(country_slug)
      BRITISH_OVERSEAS_TERRITORIES.include?(country_slug)
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

    def os_marriage_via_local_authorities?(country_slug)
      OS_MARRIAGE_VIA_LOCAL_AUTHORITIES.include?(country_slug)
    end

    def requires_7_day_notice?(ceremony_country_slug)
      REQUIRES_7_DAY_NOTICE_CEREMONY_COUNTRIES.include?(ceremony_country_slug)
    end

    def ss_unknown_no_embassies?(country_slug)
      SS_UNKNOWN_NO_EMBASSIES.include?(country_slug)
    end

    def os_consular_cni_in_nearby_country?(country_slug)
      OS_CONSULAR_CNI_IN_NEARBY_COUNTRY.include?(country_slug)
    end
  end
end
