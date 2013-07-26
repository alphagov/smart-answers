status :published
satisfies_need "2837"


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
        :outcome_travel
      when 'ccg-expenses'
        :outcome_ccg_expenses
      when 'dsa-expenses'
        :outcome_dsa_expenses
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
        :outcome_dsa_expenses
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
            :outcome_proof_identity_1314
          else
            :outcome_proof_identity_1314_pt
          end
        else 
          :outcome_proof_identity_1213
        end
      elsif form_required == 'income-details' 
        if response == 'year-1314' 
          :outcome_parent_partner_1314
        else
          :outcome_parent_partner_1213
        end
      elsif form_required == 'apply-dsa' 
        if response == 'year-1314'
          if student_type == 'uk-full-time'
            :outcome_dsa_1314
          else
            :outcome_dsa_1314_pt
          end
        else
          :outcome_dsa_1213
        end
      elsif form_required == 'apply-ccg' 
        if response == 'year-1314' 
          :outcome_ccg_1314
        else
          :outcome_ccg_1213
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
            :outcome_uk_ft_1314_continuing
          else 
            :outcome_uk_ft_1314_new
          end
        elsif year_required == 'year-1213' 
          if response == 'continuing-student' 
            :outcome_uk_ft_1213_continuing
          else 
            :outcome_uk_ft_1213_new
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
          :outcome_eu_ft_1314_continuing
        else 
          :outcome_eu_ft_1314_new
        end
      elsif year_required == "year-1213"
        if response =='continuing-student'
          :outcome_eu_ft_1213_continuing
        else
          :outcome_eu_ft_1213_new
        end
      end
    
    elsif student_type == 'eu-part-time'
      if year_required == 'year-1314'
        if response == 'continuing-student'
          :outcome_eu_pt_1314_continuing
        else
          :outcome_eu_pt_1314_new
        end
      elsif year_required == 'year-1213'
        if response =='continuing-student'
          :outcome_eu_pt_1213_continuing
        else
          :outcome_eu_pt_1213_new
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
              :outcome_uk_pt_1314_grant
            else
              :outcome_uk_pt_1314_continuing
            end
          elsif continuing_student_state == 'new-student'
            if response == 'course-start-before-01092012'
              :outcome_uk_pt_1314_grant
            else
              :outcome_uk_pt_1314_new
            end
          end
        elsif year_required == 'year-1213'
          if continuing_student_state == 'continuing-student'
            if response == 'course-start-before-01092012'
              :outcome_uk_pt_1213_grant
            else
              :outcome_uk_pt_1213_continuing
            end
          elsif continuing_student_state == 'new-student'
            if response == 'course-start-before-01092012'
              :outcome_uk_pt_1213_grant
            else
              :outcome_uk_pt_1213_new
            end
          end
        end
      end
    end
  end
end


outcome :outcome_uk_ft_1314_new
outcome :outcome_uk_ft_1314_continuing
outcome :outcome_uk_ft_1213_new
outcome :outcome_uk_ft_1213_continuing
outcome :outcome_uk_pt_1314_new
outcome :outcome_uk_pt_1314_continuing
outcome :outcome_uk_pt_1314_grant
outcome :outcome_uk_pt_1213_new
outcome :outcome_uk_pt_1213_continuing
outcome :outcome_uk_pt_1213_grant
outcome :outcome_parent_partner_1314
outcome :outcome_parent_partner_1213
outcome :outcome_proof_identity_1314
outcome :outcome_proof_identity_1314_pt
outcome :outcome_proof_identity_1213
outcome :outcome_dsa_1314
outcome :outcome_dsa_1314_pt
outcome :outcome_dsa_1213
outcome :outcome_ccg_1314
outcome :outcome_ccg_1213
outcome :outcome_dsa_expenses
outcome :outcome_ccg_expenses
outcome :outcome_travel
outcome :outcome_eu_ft_1314_new
outcome :outcome_eu_ft_1314_continuing
outcome :outcome_eu_pt_1314_new
outcome :outcome_eu_pt_1314_continuing
outcome :outcome_eu_ft_1213_new
outcome :outcome_eu_ft_1213_continuing
outcome :outcome_eu_pt_1213_new
outcome :outcome_eu_pt_1213_continuing
