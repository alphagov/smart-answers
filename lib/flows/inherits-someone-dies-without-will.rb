satisfies_need 2006
status :published

#Q0
multiple_choice :where_did_the_deceased_live? do
  option :"england-and-wales"
  option :"scotland"
  option :"northern-ireland"

  save_input_as :region
  next_node :is_there_a_living_spouse_or_civil_partner?
end

#Shared 1 EW, SC, NI
multiple_choice :is_there_a_living_spouse_or_civil_partner? do
  option :"yes"
  option :"no"

  save_input_as :living_spouse_partner

  next_node do |response|
    if response.to_s == "yes"
      if region == "england-and-wales" or region == "northern-ireland"
        :is_the_estate_worth_more_than_250000?
      else
        :are_there_living_children?
      end
    else
      if region == "england-and-wales"
        :other_living_relatives_ew?
      elsif region == "scotland"
        :living_children_sc?
      else
        :other_living_relatives_ni?
      end
    end
  end
end

#Shared 2 EW, NI
multiple_choice :is_the_estate_worth_more_than_250000? do
  option :"yes"
  option :"no"

  calculate :next_step_links do
    if responses.last == "no"
      PhraseList.new(:wills_link_only)
    end
  end

  next_node do |response|
    if response == "no"
      if region == "england-and-wales"
        :outcome_1
      else
        :outcome_25
      end
    else
      :are_there_living_children?
    end
  end
end


#Shared 3 EW, SC, NI
multiple_choice :are_there_living_children? do
  option :"yes"
  option :"no"

  calculate :next_step_links do
    if responses.last == "yes"
      PhraseList.new(:wills_and_inheritance_links)
    end
  end

  next_node do |response|
    if response.to_s == "yes"
      if region == "england-and-wales"
        :outcome_2
      elsif region == "scotland"
        :outcome_14
      else
        :more_than_one_child?
      end
    else
      :are_there_living_parents?
    end
  end
end

#NI 1
multiple_choice :more_than_one_child? do
  option :"yes" => :outcome_27
  option :"no" => :outcome_26
end

#Shared 4 EW, SC, NI
multiple_choice :are_there_living_parents? do
  option :"yes"
  option :"no"

  save_input_as :living_parents

  next_node do |response|
    if response == "yes"
      :are_there_any_brothers_or_sisters_living?    
    else
      case region
        when "england-and-wales" then :outcome_5
        when "scotland" then :are_there_any_brothers_or_sisters_living?
        when "northern-ireland" then :outcome_28
      end
    end
  end

  calculate :next_step_links do
    if region == "england-and-wales" or region == "northern-ireland"
        PhraseList.new(:wills_and_inheritance_links)
    end
  end
end

#Shared 5 EW, SC, NI
multiple_choice :are_there_any_brothers_or_sisters_living? do
  option :"yes"
  option :"no"

  calculate :next_step_links do
    if region == "scotland" or region == "northern-ireland" or region == "england-and-wales"
      PhraseList.new(:wills_and_inheritance_links)
    end
  end

  next_node do |response|
    if response == "yes"
      case region
        when "england-and-wales"
          :outcome_4
        when "northern-ireland"
          :outcome_29
        when "scotland"
          if living_parents == "yes"
            :outcome_15a
          else
            :outcome_15b
          end
      end
    else
      case region
        when "england-and-wales"
          :outcome_3
        when "northern-ireland"
          :outcome_30
        when "scotland"
          if living_parents == "yes"
            :outcome_16a
          else
            :outcome_16b
          end
        end
      end
    end
  end


#EW 1
multiple_choice :other_living_relatives_ew? do
  option :"living-children-ew"
  option :"living-parents-ew"
  option :"siblings-same-parents-ew"
  option :"siblings-halfblood-ew"
  option :"living-grandparents-ew"
  option :"aunts-or-uncles-ew"
  option :"aunts-or-uncles-halfblood-ew"
  option :"no-living-relatives-ew"

  calculate :next_step_links do
    if responses.last == "no-living-relatives-ew"
      PhraseList.new(:bona_vacantia_link_only)
    else
      PhraseList.new(:wills_and_inheritance_links)
    end
  end 

  next_node do |response|
    case response.to_s
      when "living-children-ew"
        :outcome_6
      when "living-parents-ew"
        :outcome_7
      when "siblings-same-parents-ew"
        :outcome_8
      when "siblings-halfblood-ew"
        :outcome_9
      when "living-grandparents-ew"
        :outcome_10
      when "aunts-or-uncles-ew"
        :outcome_11
      when "aunts-or-uncles-halfblood-ew"
        :outcome_12
      else
        :outcome_13
    end
  end
end

#SC 1
multiple_choice :living_children_sc? do
  option :"yes" => :outcome_17
  option :"no" => :living_parents_sc?

    calculate :next_step_links do
    if region == "scotland" or region == "northern-ireland" or region == "england-and-wales"
      PhraseList.new(:wills_and_inheritance_links)
    end
  end

end

#SC 2
multiple_choice :living_parents_sc? do
  option :"yes" => :siblings_same_parents_sc?
  option :"no" => :siblings_same_parents_sc?

  save_input_as :living_parents
end

#SC 3
multiple_choice :siblings_same_parents_sc? do
  option :"yes"
  option :"no"

  calculate :next_step_links do
    if region == "scotland" or region == "northern-ireland" or region == "england-and-wales"
      PhraseList.new(:wills_and_inheritance_links)
    end
  end

  next_node do |response|
    if response.to_s == "yes"
      if living_parents == "yes"
        :outcome_18
      else
        :outcome_20
      end
    else
      if living_parents =="yes"
        :outcome_19
      else
        :aunts_or_uncles_sc?
      end
    end
  end
end

#SC 4
multiple_choice :aunts_or_uncles_sc? do
  option :"yes" => :outcome_21
  option :"no" => :living_grandparents_sc?
end

#SC 5
multiple_choice :living_grandparents_sc? do
  option :"yes" => :outcome_22
  option :"no" => :great_aunts_or_uncles_sc?
end

#SC 6
multiple_choice :great_aunts_or_uncles_sc? do
  option :"yes" => :outcome_23
  option :"no" => :outcome_24

  calculate :next_step_links do
    if responses.last == "yes"
      PhraseList.new(:wills_and_inheritance_links)
    else
      PhraseList.new(:bona_vacantia_link_only)
    end
  end
end

multiple_choice :other_living_relatives_ni? do
  option :"living-children-ni"
  option :"living-parents-ni"
  option :"siblings-same-parents-ni"
  option :"aunts-or-uncles-ni"
  option :"living-grandparents-ni"
  option :"no-living-relatives-ni"

  calculate :next_step_links do
    if responses.last == "no-living-relatives-ni"
      PhraseList.new(:bona_vacantia_link_only)
    else
      PhraseList.new(:wills_and_inheritance_links)
    end
  end 

  next_node do |response|
    case response.to_s
      when "living-children-ni"
        :outcome_31
      when "living-parents-ni"
        :outcome_32
      when "siblings-same-parents-ni"
        :outcome_33
      when "aunts-or-uncles-ni"
        :outcome_34
      when "living-grandparents-ni"
        :outcome_35
      else
        :outcome_36
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
outcome :outcome_15a
outcome :outcome_15b
outcome :outcome_16a
outcome :outcome_16b
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
outcome :outcome_32
outcome :outcome_33
outcome :outcome_34
outcome :outcome_35
outcome :outcome_36

