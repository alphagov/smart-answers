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
  end
end
