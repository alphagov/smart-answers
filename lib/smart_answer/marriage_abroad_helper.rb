module SmartAnswer
  module MarriageAbroadHelper
    def ceremony_type(calculator)
      if calculator.partner_is_opposite_sex?
        'Marriage'
      else
        'Civil partnership'
      end
    end

    def ceremony_type_lowercase(calculator)
      ceremony_type(calculator).downcase
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
