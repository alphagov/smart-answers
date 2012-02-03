status :draft

section_slug "family"
subsection_slug "marriage-and-civil-partnership"
satisfies_need 2012

multiple_choice :were_you_or_your_partner_born_on_or_before_6_april_1935? do
  option :yes => :did_you_marry_or_civil_partner_before_5_december_2005?
  option :no => :sorry
end

multiple_choice :did_you_marry_or_civil_partner_before_5_december_2005? do
  option :yes
  option :no

  calculate :result_strings do
    (responses.last == :yes) ? PhraseList.new(:before_2005) : PhraseList.new(:after_2005)
  end

  next_node :whats_your_income?
end

money_question :whats_your_income? do

  calculate :allowance do
    if responses.last > 24000
      income = (responses.last - 24000)/2 - 2651
      income = (7295-income) * 0.1
      (income < 280) ? Money.new(280) : Money.new(income)
    else
      Money.new(729.50)
    end
  end

  next_node :done
end

outcome :sorry