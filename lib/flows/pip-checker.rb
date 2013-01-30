status :published
satisfies_need 2698

## Q1
multiple_choice :are_you_getting_dla? do
  option :yes => :what_is_your_dob?
  option :no => :what_is_your_post_code?

  # Used in later questions
  calculate :calculator do
    Calculators::PIPDates.new
  end

  calculate :getting_dla do
    responses.last == 'yes'
  end
end

## Q2 
value_question :what_is_your_post_code? do
  calculate :in_selected_area do
    calculator.postcode = responses.last
    raise SmartAnswer::InvalidResponse unless calculator.valid_postcode?
    calculator.in_selected_area?
  end

  next_node :what_is_your_dob?
end

## Q3
date_question :what_is_your_dob? do
  from { Date.today - 100.years }
  to { Date.today }
  next_node do |response|
    calculator.dob = Date.parse(response)
    if getting_dla
      if calculator.in_group_65?
        :result_7
      elsif calculator.turning_16_before_oct_2013?
        :result_5
      elsif calculator.in_middle_group?
        :result_8
      else
        :result_6
      end
    else
      if calculator.in_group_65?
        :result_2
      elsif calculator.in_middle_group?
        if in_selected_area
          :result_3
        else
          :result_4
        end
      else
        :result_1
      end
    end
  end
end

outcome :result_1
outcome :result_2
outcome :result_3
outcome :result_4
outcome :result_5
outcome :result_6
outcome :result_7
outcome :result_8
