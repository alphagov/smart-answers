module SmartAnswer
  module MarriageAbroadHelper
    def ceremony_type(sex_of_your_partner)
      if sex_of_your_partner == 'opposite_sex'
        'Marriage'
      else
        'Civil partnership'
      end
    end
  end
end
