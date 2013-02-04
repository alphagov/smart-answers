status :published



## Q1
multiple_choice :type_of_student? do
  option :"uk-full-time" 
  option :"uk-part-time"
  option :"eu-full-time"
  option :"eu-part-time"

 save_input_as :student_type

  calculate :form_destination do
    if responses.last == 'uk-full-time' or responses.last == 'uk-part-time'
      PhraseList.new(:postal_address_uk)
    else
      PhraseList.new(:postal_address_eu)
    end
  end

  next_node do |response|
    case response.to_s
      when 'uk-full-time'
        :form_needed_for_1?
      when "uk-part-time"
        :form_needed_for_2?
      else
        :what_year?
    end
  end
end

 
## Q2a
multiple_choice :form_needed_for_1? do
  option :"apply-loans-grants"
  option :"proof-identity"
  option :"income-details"
  option :"apply-dsa"
  option :"dsa-expenses"
  option :"apply-ccg"
  option :"ccg-expenses"
  option :"travel-grant"

  save_input_as :form_required

  next_node do |response|
    case response.to_s
      when 'travel-grant'
        :outcome_23
      when 'ccg-expenses'
        :outcome_22
      when 'dsa-expenses'
        :outcome_21 
      else
        :what_year?      
    end
  end
end

## Q2b
multiple_choice :form_needed_for_2? do
  option :"apply-loans-grants"
  option :"proof-identity"
  option :"apply-dsa"
  option :"dsa-expenses"

  save_input_as :form_required

  next_node do |response|
    case response.to_s
      when 'dsa-expenses'
        :outcome_21
      else
        :what_year?     
    end
  end
end


## Q3
multiple_choice :what_year? do
  option :"year-1314"
  option :"year-1213"

  save_input_as :year_required

  next_node do |response|
    if student_type == 'uk-full-time' or student_type == 'uk-part-time' 
      if form_required == 'apply-loans-grants' 
        :continuing_student?
      elsif form_required == 'proof-identity' 
        if response == 'year-1314'
          if student_type == 'uk-full-time'
            :outcome_13
          else
            :outcome_14
          end
        else 
          :outcome_15
        end
      elsif form_required == 'income-details' 
        if response == 'year-1314' 
          :outcome_11 
        else
          :outcome_12 
        end
      elsif form_required == 'apply-dsa' 
        if response == 'year-1314'
          if student_type == 'uk-full-time'
            :outcome_16
          else
            :outcome_17
          end
        else
          :outcome_18 
        end
      elsif form_required == 'apply-ccg' 
        if response == 'year-1314' 
          :outcome_19 
        else
          :outcome_20
        end
      end
    else
      :continuing_student?
    end
  end
end


## Q4
multiple_choice :continuing_student? do
  option :"continuing-student"
  option :"new-student"

  save_input_as :continuing_student_state
  next_node do |response|

    if student_type == "uk-full-time" 
      if form_required == "apply-loans-grants"  
        if year_required == "year-1314" 
          if response == "continuing-student" 
            :outcome_2 
          else 
            :outcome_1 
          end
        elsif year_required == 'year-1213' 
          if response == 'continuing-student' 
            :outcome_4 
          else 
            :outcome_3 
          end
        end
      end
    
    elsif student_type == 'uk-part-time' 
      if form_required == 'apply-loans-grants'
        :pt_course_start?
      end
        
    elsif student_type == 'eu-full-time'
      if year_required == "year-1314" 
        if response == 'continuing-student'
          :outcome_25
        else 
          :outcome_24
        end
      elsif year_required == "year-1213"
        if response =='continuing-student'
          :outcome_29
        else
          :outcome_28
        end
      end
    
    elsif student_type == 'eu-part-time'
      if year_required == 'year-1314'
        if response == 'continuing-student'
          :outcome_27
        else
          :outcome_26
        end
      elsif year_required == 'year-1213'
        if response =='continuing-student'
          :outcome_31
        else
          :outcome_30
        end
      end
    end

  end
end


##Q5
multiple_choice :pt_course_start? do
  option :"course-start-before-01092012"
  option :"course-start-after-01092012"

  next_node do |response|
    if student_type == 'uk-part-time'
      if form_required == 'apply-loans-grants'
        if year_required == 'year-1314'
          if continuing_student_state == 'continuing-student'
            if response == 'course-start-before-01092012'
              :outcome_7
            else
              :outcome_6
            end
          elsif continuing_student_state == 'new-student'
            if response == 'course-start-before-01092012'
              :outcome_7
            else
              :outcome_5
            end
          end
        elsif year_required == 'year-1213'
          if continuing_student_state == 'continuing-student'
            if response == 'course-start-before-01092012'
              :outcome_10
            else
              :outcome_9 
            end
          elsif continuing_student_state == 'new-student'
            if response == 'course-start-before-01092012'
              :outcome_10 
            else
              :outcome_8 
            end
          end
        end
      end
    end
  end
end


outcome :outcome_1
outcome :outcome_2
outcome :outcome_3
outcome :outcome_4
outcome :outcome_5
outcome :outcome_6
outcome :outcome_7
outcome :outcome_8
outcome :outcome_9
outcome :outcome_10
outcome :outcome_11
outcome :outcome_12
outcome :outcome_13
outcome :outcome_14
outcome :outcome_15
outcome :outcome_16
outcome :outcome_17
outcome :outcome_18
outcome :outcome_19
outcome :outcome_20
outcome :outcome_21
outcome :outcome_22
outcome :outcome_23
outcome :outcome_24
outcome :outcome_25
outcome :outcome_26
outcome :outcome_27
outcome :outcome_28
outcome :outcome_29
outcome :outcome_30
outcome :outcome_31
