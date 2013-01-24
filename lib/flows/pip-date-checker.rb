status :draft

## Q1
value_question :what_is_your_post_code? do

  calculate :calculator do
    calc = Calculators::PIPDates.new(responses.last)
    raise SmartAnswer::InvalidResponse unless calc.valid_postcode?
    calc
  end
  calculate :in_selected_area do
    calculator.in_selected_area?
  end

  next_node :are_you_getting_dla?
end

## Q2 
multiple_choice :are_you_getting_dla? do
  option :yes
  option :no

  next_node do |response|
    if response == 'yes'
      :when_does_your_dla_end?
    else
      if in_selected_area
        :result_1
      else
        :result_2
      end
    end
  end
end

## Q3
date_question :when_does_your_dla_end? do
  calculate :dla_end_date do
    calculator.dla_end_date = Date.parse(responses.last)
  end

  next_node :what_is_your_dob?
end

## Q4
date_question :what_is_your_dob? do
  next_node do |response|
    calculator.dob = Date.parse(response)
    if calculator.in_group_65?
      :result_3
    elsif calculator.in_middle_group?
      if calculator.dla_continues?
        :result_4
      else
        :result_5
      end
    else
      :result_6
    end
  end
end

outcome :result_1
outcome :result_2
outcome :result_3
outcome :result_4
outcome :result_5
outcome :result_6
