status :draft
satisfies_need ""

exclude_countries = %w(american-samoa aruba bonaire-st-eustatius-saba british-antarctic-territory british-indian-ocean-territory curacao french-guiana french-polynesia gibraltar guadeloupe holy-see martinique mayotte new-caledonia reunion st-maarten st-pierre-and-miquelon wallis-and-futuna western-sahara)

country_group_ukot = %w(anguilla bermuda british-virgin-islands falkland-islands montserrat pitcairn-island st-helena-ascension-and-tristan-da-cunha south-georgia-and-south-sandwich-islands turks-and-caicos-islands)

country_group_non_visa_national = %w(andorra antigua-and-barbuda argentina australia bahamas barbados belize botswana brazil brunei canada chile costa-rica dominica timor-leste el-salvador grenada guatemala honduras  hong-kong israel japan kiribati south-korea macao malaysia maldives marshall-islands mauritius mexico micronesia monaco namibia nauru new-zealand nicaragua palau panama papua-new-guinea paraguay st-kitts-and-nevis st-lucia st-vincent-and-the-grenadines samoa san-marino seychelles singapore solomon-islands taiwan tonga trinidad-and-tobago tuvalu usa uruguay vanuatu)

country_group_visa_national = %w(armenia azerbaijan bahrain benin bhutan bosnia-and-herzegovina burkina-faso cambodia cape-verde central-african-republic chad china comoros cuba djibouti dominican-republic egypt equatorial-guinea fiji gabon georgia guyana haiti india indonesia jordan kazakhstan korea kuwait kyrgyzstan laos libya madagascar mali mauritania morocco mozambique niger pakistan peru philippines qatar russia sao-tome-and-principe saudi-arabia suriname syria tajikistan thailand togo tunisia turkmenistan ukraine united-arab-emirates uzbekistan vietnam yemen zambia
)

country_group_datv = %w(afghanistan albania algeria angola bangladesh belarus bolivia burma burundi cameroon china colombia congo democratic-republic-of-congo ecuador eritrea ethiopia gambia ghana guinea guinea-bissau india iran iraq cote-d-ivoire jamaica kenya kosovo lebanon lesotho liberia macedonia malawi moldova mongolia montenegro nepal nigeria oman the-occupied-palestinian-territories rwanda senegal serbia sierra-leone somalia south-africa south-sudan sri-lanka sudan swaziland tanzania turkey uganda venezuela vietnam zimbabwe)

country_group_eea = %w(austria belgium bulgaria croatia cyprus czech republic denmark estonia finland france germany greece hungary iceland ireland italy latvia liechtenstein lithuania luxemburg malta netherlands norway poland portugal romania slovakia slovenia spain sweden switzerland)

# Q1
country_select :what_nationality_are_you?, :exclude_countries => exclude_countries do
  save_input_as :country_group

  calculate :location do
    loc = WorldLocation.find(current_location)
    raise InvalidResponse unless loc
    loc
  end

  next_node :just_testing
end





outcome :just_testing