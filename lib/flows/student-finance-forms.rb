status :draft
satisfies_need "?"


## Q1
multiple_choice :type_of_student? do
  option 1 
  option 2
  option 3
  option 4 

 save_input_as :student_type

  calculate :form_destination do
    if responses.last < '3'
      PhraseList.new(:postal_address_uk)
    else
      PhraseList.new(:postal_address_eu)
    end
  end

  next_node do |response|
    case response.to_i
      when 1
        :form_needed_for_1?
      when 2
        :form_needed_for_2?
      else
        :what_year?
    end
  end
end

 
## Q2a
multiple_choice :form_needed_for_1? do
  option 1 
  option 2 
  option 3
  option 4 
  option 5 
  option 6 
  option 7 
  option 8 

  save_input_as :form_required

  next_node do |response|
    case response.to_i
      when 1, 2, 3, 4, 6
        :what_year?
      when 5
        :outcome_19
      when 7
        :outcome_20
      else
        :outcome_21
    end
  end
end

## Q2b
multiple_choice :form_needed_for_2? do
  option 1 
  option 2 
  option 4 
  option 5 

  save_input_as :form_required

  next_node do |response|
    case response.to_i
      when 5
        :outcome_19
      else
        :what_year?
    end
  end
end


## Q3
multiple_choice :what_year? do
  option 1
  option 2

  save_input_as :year_required

  next_node do |response|
    if student_type < '3'  #uk_ft/uk_pt
      if form_required == '1' #apply_student_finance
        :continuing_student?
      elsif form_required == '2' #proof_identity
        if response == '1' #1314
          :outcome_13 #uk_ft/uk_pt proof_identity_1314
        else #1213
          :outcome_14 #uk_ft/uk_pt proof_identity_1213
        end
      elsif form_required == '3' #parent_partner
        if response == '1' #1314
          :outcome_11 #uk_ft parent_partner_1314
        else #1213
          :outcome_12 #uk_ft parent_partner_1213
        end
      elsif form_required == '4' #apply_dsa
        if response == '1' #1314
          :outcome_15 #uk_ft/uk_pt apply_dsa_1314
        else #1213
          :outcome_16 #uk_ft/uk_pt apply_dsa_1213
        end
      elsif form_required == '6' #apply_ccg
        if response == '1' #1314
          :outcome_17 #uk_ft/uk_pt apply_ccg_1314
        else #1213
          :outcome_18 #uk_ft/uk_pt apply_ccg_1213
        end
      end      
    elsif student_type > '2' #eu_ft/eu_pt
      :continuing_student?
    end
  end
end


## Q4
multiple_choice :continuing_student? do
  option 1
  option 2

  save_input_as :continuing_student_state
  next_node do |response|

    if student_type == '1' #uk_ft
      if form_required == '1'  #apply_student_finance
        if year_required == '1' #1314
          if response == '1' #continuing
            :outcome_2 #uk_ft_apply_student_finance_1314_continuing
          else #new
            :outcome_1 #uk_ft_apply_student_finance_1314_new
          end
        elsif year_required == '2' # 1213
          if response == '1' # continuing
            :outcome_4 #uk_ft_apply_student_finance_1213_continuing
          else #new
            :outcome_3 #uk_ft_apply_student_finance_1213_new
          end
        end
      end
    
    elsif student_type == '2' #uk_pt
      if form_required == '1'  #apply_student_finance
        :pt_course_start?
      end
        
    elsif student_type == '3' #eu_ft
      if year_required == '1'  #1314
        if response == '1' #continuing
          :outcome_23 #eu_ft_1314_continuing
        else #new
          :outcome_22 #eu_ft_1314_new
        end
      elsif year_required == '2' #1213
        if response =='1' #continuing
          :outcome_27 #eu_ft_1213_continuing
        else #new
          :outcome_26 #eu_ft_1213_new
        end
      end
    
    elsif student_type == '4' #eu_pt
      if year_required == '1'  #1314
        if response == '1' #continuing
          :outcome_25 #eu_pt_1314_continuing
        else #new
          :outcome_24 #eu_pt_1314_new
        end
      elsif year_required == '2' #1213
        if response =='1' #continuing
          :outcome_29 #eu_pt_1213_continuing
        else # new
          :outcome_28 #eu_pt_1213_new
        end
      end
    end
        
  end
end


##Q5
multiple_choice :pt_course_start? do
  option 1
  option 2

  next_node do |response|
    if student_type == '2' #uk_pt
      if form_required == '1'  #apply
        if year_required == '1' #1314
          if continuing_student_state == '1' # continuing
            if response == '1' #before 01/09/12
              :outcome_7 #uk_pt_apply_student_finance_1314_grant
            else #after 01/09/12
              :outcome_6 #uk_pt_apply_student_finance_1314_continuing
            end
          elsif continuing_student_state == '2' #new
            if response == '1' #before 01/09/12
              :outcome_7 #uk_pt_apply_student_finance_1314_grant
            else #after 01/09/12
              :outcome_5 #uk_pt_apply_student_finance_1314_new
            end
          end
        elsif year_required == '2' #1213
            if continuing_student_state == '1' # continuing
            if response == '1' #before 01/09/12
              :outcome_10 #uk_pt_apply_student_finance_1213_grant
            else #after 01/09/12
              :outcome_9 #uk_pt_apply_student_finance_1314_continuing
            end
          elsif continuing_student_state == '2' #new
            if response == '1' #before 01/09/12
              :outcome_10 #uk_pt_apply_student_finance_1213_grant
            else #after 01/09/12
              :outcome_8 #uk_pt_apply_student_finance_1213_new
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
