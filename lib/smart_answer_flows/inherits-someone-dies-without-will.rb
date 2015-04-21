status :published
satisfies_need "100988"

# The case & if blocks in this file are organised to be read in the same order
# as the flow chart rather than to minimise repetition.

# Q1
multiple_choice :region? do
  option :"england-and-wales"
  option :"scotland"
  option :"northern-ireland"

  save_input_as :region

  calculate :next_step_links do
    PhraseList.new(:wills_link, :inheritance_link)
  end

  next_node :partner?
end

# Q2
multiple_choice :partner? do
  option :"yes"
  option :"no"

  save_input_as :partner

  on_condition(variable_matches(:region, 'england-and-wales') | variable_matches(:region, 'northern-ireland')) do
    next_node_if(:estate_over_250000?, responded_with('yes'))
    next_node_if(:children?, responded_with('no'))
  end
  on_condition(variable_matches(:region, 'scotland')) do
    next_node(:children?)
  end
end

# Q3
multiple_choice :estate_over_250000? do
  option :"yes"
  option :"no"

  save_input_as :estate_over_250000

  calculate :next_step_links do
    if estate_over_250000 == "yes"
      next_step_links
    else
      PhraseList.new(:wills_link)
    end
  end

  on_condition(variable_matches(:region, 'england-and-wales')) do
    next_node_if(:children?, responded_with('yes'))
    next_node_if(:outcome_1, responded_with('no'))
  end
  on_condition(variable_matches(:region, 'northern-ireland')) do
    next_node_if(:children?, responded_with('yes'))
    next_node_if(:outcome_60, responded_with('no'))
  end
end

# Q4
multiple_choice :children? do
  option :"yes"
  option :"no"

  save_input_as :children

  on_condition(variable_matches(:region, 'england-and-wales')) do
    on_condition(variable_matches(:partner, 'yes')) do
      next_node_if(:outcome_20, responded_with('yes'))
      next_node_if(:outcome_1, responded_with('no'))
    end
    on_condition(variable_matches(:partner, 'no')) do
      next_node_if(:outcome_2, responded_with('yes'))
      next_node_if(:parents?, responded_with('no'))
    end
  end
  on_condition(variable_matches(:region, 'scotland')) do
    on_condition(variable_matches(:partner, 'yes')) do
      next_node_if(:outcome_40, responded_with('yes'))
      next_node_if(:parents?, responded_with('no'))
    end
    on_condition(variable_matches(:partner, 'no')) do
      next_node_if(:outcome_2, responded_with('yes'))
      next_node_if(:parents?, responded_with('no'))
    end
  end
  on_condition(variable_matches(:region, 'northern-ireland')) do
    on_condition(variable_matches(:partner, 'yes')) do
      next_node_if(:more_than_one_child?, responded_with('yes'))
      next_node_if(:parents?, responded_with('no'))
    end
    on_condition(variable_matches(:partner, 'no')) do
      next_node_if(:outcome_66, responded_with('yes'))
      next_node_if(:parents?, responded_with('no'))
    end
  end
end

# Q5
multiple_choice :parents? do
  option :"yes"
  option :"no"

  save_input_as :parents

  next_node do |response|
    case region
    when "england-and-wales"
      if partner == "yes"
        response == "yes" ? :outcome_21 : :siblings?
      else
        response == "yes" ? :outcome_3 : :siblings?
      end
    when "scotland"
      :siblings?
    when "northern-ireland"
      if partner == "yes"
        response == "yes" ? :outcome_63 : :siblings_including_mixed_parents?
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

  next_node do |response|
    case region
    when "england-and-wales"
      if partner == "yes"
        response == "yes" ? :outcome_22 : :outcome_1
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
        response == "yes" ? :outcome_4 : :grandparents?
      end
    end
  end
end

# Q61
multiple_choice :siblings_including_mixed_parents? do
  option :"yes"
  option :"no"

  save_input_as :siblings

  next_node do |response|
    response == "yes" ? :outcome_64 : :outcome_65
  end
end

# Q7
multiple_choice :grandparents? do
  option :"yes"
  option :"no"

  save_input_as :grandparents

  next_node do |response|
    case region
    when "england-and-wales"
      response == "yes" ? :outcome_5 : :aunts_or_uncles?
    when "scotland"
      response == "yes" ? :outcome_5 : :great_aunts_or_uncles?
    when "northern-ireland"
      response == "yes" ? :outcome_5 : :aunts_or_uncles?
    end
  end
end

# Q8
multiple_choice :aunts_or_uncles? do
  option :"yes"
  option :"no"

  save_input_as :aunts_or_uncles

  next_node do |response|
    case region
    when "england-and-wales"
      response == "yes" ? :outcome_6 : :half_aunts_or_uncles?
    when "scotland"
      response == "yes" ? :outcome_6 : :grandparents?
    when "northern-ireland"
      response == "yes" ? :outcome_6 : :outcome_67
    end
  end
end

# Q20
multiple_choice :half_siblings? do
  option :"yes"
  option :"no"

  save_input_as :half_siblings

  next_node do |response|
    response == "yes" ? :outcome_23 : :grandparents?
  end
end

# Q21
multiple_choice :half_aunts_or_uncles? do
  option :"yes"
  option :"no"

  save_input_as :half_aunts_or_uncles

  next_node do |response|
    response == "yes" ? :outcome_24 : :outcome_25
  end
end

# Q40
multiple_choice :great_aunts_or_uncles? do
  option :"yes"
  option :"no"

  save_input_as :great_aunts_or_uncles

  next_node do |response|
    response == "yes" ? :outcome_45 : :outcome_46
  end
end

# Q60
multiple_choice :more_than_one_child? do
  option :"yes"
  option :"no"

  save_input_as :more_than_one_child

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

outcome :outcome_25 do
  precalculate :next_step_links do
    PhraseList.new(:ownerless_link)
  end
end

outcome :outcome_40
outcome :outcome_41
outcome :outcome_42
outcome :outcome_43
outcome :outcome_44
outcome :outcome_45

outcome :outcome_46 do
  precalculate :next_step_links do
    PhraseList.new(:ownerless_link)
  end
end

outcome :outcome_60
outcome :outcome_61
outcome :outcome_62
outcome :outcome_63
outcome :outcome_64
outcome :outcome_65
outcome :outcome_66

outcome :outcome_67 do
  precalculate :next_step_links do
    PhraseList.new(:ownerless_link)
  end
end
