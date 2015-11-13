module SmartAnswer::Calculators
  class UkVisaCalculator
    EXCLUDE_COUNTRIES = %w(american-samoa british-antarctic-territory british-indian-ocean-territory french-guiana french-polynesia gibraltar guadeloupe holy-see martinique mayotte new-caledonia reunion st-pierre-and-miquelon the-occupied-palestinian-territories wallis-and-futuna western-sahara)

    COUNTRY_GROUP_UKOT = %w(anguilla bermuda british-dependent-territories-citizen british-overseas-citizen british-protected-person british-virgin-islands cayman-islands falkland-islands montserrat st-helena-ascension-and-tristan-da-cunha south-georgia-and-south-sandwich-islands turks-and-caicos-islands)

    COUNTRY_GROUP_NON_VISA_NATIONAL = %w(andorra antigua-and-barbuda argentina aruba australia bahamas barbados belize bonaire-st-eustatius-saba botswana brazil british-national-overseas brunei canada chile costa-rica curacao dominica timor-leste el-salvador grenada guatemala honduras hong-kong hong-kong-(british-national-overseas) israel japan kiribati south-korea macao malaysia maldives marshall-islands mauritius mexico micronesia monaco namibia nauru new-zealand nicaragua palau panama papua-new-guinea paraguay pitcairn-island st-kitts-and-nevis st-lucia st-maarten st-vincent-and-the-grenadines samoa san-marino seychelles singapore solomon-islands tonga trinidad-and-tobago tuvalu usa uruguay vanuatu vatican-city)

    COUNTRY_GROUP_VISA_NATIONAL = %w(stateless-or-refugee armenia azerbaijan bahrain benin bhutan bolivia bosnia-and-herzegovina burkina-faso cambodia cape-verde central-african-republic chad colombia comoros cuba djibouti dominican-republic ecuador equatorial-guinea fiji gabon georgia guyana haiti indonesia jordan kazakhstan north-korea kuwait kyrgyzstan laos madagascar mali  montenegro mauritania morocco mozambique niger oman peru philippines qatar russia sao-tome-and-principe saudi-arabia suriname tajikistan taiwan thailand togo tunisia turkmenistan ukraine united-arab-emirates uzbekistan zambia)
  end
end
