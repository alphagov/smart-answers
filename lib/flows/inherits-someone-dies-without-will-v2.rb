satisfies_need 2006
status :draft

# The case & if blocks in this file are organised to be read in the same order
# as the flow chart rather than to minimise repetition.

# Q1
multiple_choice :region? do
  option :"england-and-wales"
  option :"scotland"
  option :"northern-ireland"

  save_input_as :region

  next_node :partner?
end

# Q2
multiple_choice :partner? do
  option :"yes"
  option :"no"

  save_input_as :partner

  next_node do |response|
    case region
    when "england-and-wales", "northern-ireland"
      response == "yes" ? :estate_over_250000? : :children?
    when "scotland"
      :children?
    end
  end
end

# Q3
multiple_choice :estate_over_250000? do
  option :"yes"
  option :"no"

  save_input_as :estate_over_250000

  calculate :next_step_links do
    PhraseList.new(:wills_link)
  end

  next_node do |response|
    case region
    when "england-and-wales"
      response == "yes" ? :children? : :outcome_1
    when "northern-ireland"
      response == "yes" ? :children? : :outcome_60
    end
  end
end

# Q4
multiple_choice :children? do
  option :"yes"
  option :"no"

  save_input_as :children

  calculate :next_step_links do
    PhraseList.new(:wills_link, :inheritance_link)
  end

  next_node do |response|
    case region
    when "england-and-wales"
      if partner == "yes"
        response == "yes" ? :outcome_20 : :parents?
      else
        response == "yes" ? :outcome_2 : :parents?
      end
    when "scotland"
      if partner == "yes"
        response == "yes" ? :outcome_40 : :parents?
      else
        response == "yes" ? :outcome_2 : :parents?
      end
    when "northern-ireland"
      if partner == "yes"
        response == "yes" ? :more_than_one_child? : :parents?
      else
        response == "yes" ? :outcome_66 : :parents?
      end
    end
  end
end

# Q5
multiple_choice :parents? do
  option :"yes"
  option :"no"

  save_input_as :parents

  calculate :next_step_links do
    PhraseList.new(:wills_link, :inheritance_link)
  end

  next_node do |response|
    case region
    when "england-and-wales"
      if partner == "yes"
        response == "yes" ? :siblings? : :outcome_1
      else
        response == "yes" ? :outcome_3 : :siblings?
      end
    when "scotland"
      :siblings?
    when "northern-ireland"
      if partner == "yes"
        response == "yes" ? :siblings? : :outcome_63
      else
        response == "yes" ? :outcome_3 : :siblings?
      end
    end
  end
end

# Q6
multiple_choice :siblings? do
  option :"yes"
  option :"no"

  save_input_as :siblings

  calculate :next_step_links do
    PhraseList.new(:wills_link, :inheritance_link)
  end

  next_node do |response|
    case region
    when "england-and-wales"
      if partner == "yes"
        response == "yes" ? :outcome_22 : :outcome_21
      else
        response == "yes" ? :outcome_4 : :half_siblings?
      end
    when "scotland"
      if partner == "yes"
        if parents == "yes"
          response == "yes" ? :outcome_43 : :outcome_42
        else
          response == "yes" ? :outcome_41 : :outcome_1
        end
      else
        if parents == "yes"
          response == "yes" ? :outcome_44 : :outcome_3
        else
          response == "yes" ? :outcome_4 : :aunts_or_uncles?
        end
      end
    when "northern-ireland"
      if partner == "yes"
        response == "yes" ? :outcome_64 : :outcome_65
      else
        response == "yes" ? :outcome_4 : :aunts_or_uncles?
      end
    end
  end
end

# Q7
multiple_choice :grandparents? do
  option :"yes"
  option :"no"

  save_input_as :grandparents

  calculate :next_step_links do
    if region == "northern-ireland" && grandparents == "no"
      PhraseList.new(:ownerless_link)
    else
      PhraseList.new(:wills_link, :inheritance_link)
    end
  end

  next_node do |response|
    case region
    when "england-and-wales"
      response == "yes" ? :outcome_5 : :aunts_or_uncles?
    when "scotland"
      response == "yes" ? :outcome_5 : :great_aunts_or_uncles?
    when "northern-ireland"
      response == "yes" ? :outcome_5 : :outcome_67
    end
  end
end

# Q8
multiple_choice :aunts_or_uncles? do
  option :"yes"
  option :"no"

  save_input_as :aunts_or_uncles

  calculate :next_step_links do
    PhraseList.new(:wills_link, :inheritance_link)
  end

  next_node do |response|
    case region
    when "england-and-wales"
      response == "yes" ? :outcome_6 : :half_aunts_or_uncles?
    when "scotland"
      response == "yes" ? :outcome_6 : :grandparents?
    when "northern-ireland"
      response == "yes" ? :outcome_6 : :grandparents?
    end
  end
end

# Q20
multiple_choice :half_siblings? do
  option :"yes"
  option :"no"

  save_input_as :half_siblings

  calculate :next_step_links do
    PhraseList.new(:wills_link, :inheritance_link)
  end

  next_node do |response|
    response == "yes" ? :outcome_23 : :grandparents?
  end
end

# Q21
multiple_choice :half_aunts_or_uncles? do
  option :"yes"
  option :"no"

  save_input_as :half_aunts_or_uncles

  calculate :next_step_links do
    if half_aunts_or_uncles == "yes"
      PhraseList.new(:wills_link, :inheritance_link)
    else
      PhraseList.new(:ownerless_link)
    end
  end

  next_node do |response|
    response == "yes" ? :outcome_24 : :outcome_25
  end
end

# Q40
multiple_choice :great_aunts_or_uncles? do
  option :"yes"
  option :"no"

  save_input_as :great_aunts_or_uncles

  calculate :next_step_links do |state|
    if great_aunts_or_uncles == "yes"
      PhraseList.new(:wills_link, :inheritance_link)
    else
      PhraseList.new(:ownerless_link)
    end
  end

  next_node do |response|
    response == "yes" ? :outcome_45 : :outcome_46
  end
end

# Q60
multiple_choice :more_than_one_child? do
  option :"yes"
  option :"no"

  save_input_as :more_than_one_child

  calculate :next_step_links do
    PhraseList.new(:wills_link, :inheritance_link)
  end

  next_node do |response|
    response == "yes" ? :outcome_61 : :outcome_62
  end
end

outcome :outcome_1
outcome :outcome_2
outcome :outcome_3
outcome :outcome_4
outcome :outcome_5
outcome :outcome_6

outcome :outcome_20
outcome :outcome_21
outcome :outcome_22
outcome :outcome_23
outcome :outcome_24
outcome :outcome_25

outcome :outcome_40
outcome :outcome_41
outcome :outcome_42
outcome :outcome_43
outcome :outcome_44
outcome :outcome_45
outcome :outcome_46

outcome :outcome_60
outcome :outcome_61
outcome :outcome_62
outcome :outcome_63
outcome :outcome_64
outcome :outcome_65
outcome :outcome_66
outcome :outcome_67
