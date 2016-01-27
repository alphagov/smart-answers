module SmartAnswer
  module MarriageAbroadHelper
    def ceremony_type(sex_of_your_partner)
      if sex_of_your_partner == 'opposite_sex'
        'Marriage'
      else
        'Civil partnership'
      end
    end

    def ceremony_type_lowercase(sex_of_your_partner)
      ceremony_type(sex_of_your_partner).downcase
    end

    def specific_local_authorities(country_slug)
      {
        "cambodia" => " (the local district office, ‘Sangkat’, and the Ministry of Foreign Affairs)",
        "germany"  => " (registry office ‘standesamt’ or church) ",
        "greece"   => " (the town hall or the local priest)",
        "oman"     => " (the local church, mosque or temple) ",
        "poland"   => " (the local registry office or church)"
      }[country_slug].to_s
    end
  end
end
