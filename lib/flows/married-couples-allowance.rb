status :draft

section_slug "family"
subsection_slug "marriage-and-civil-partnership"
satisfies_need 2012

class MarriedCouplesAllowanceAnswer
  def self.calculate_allowance(amount)
    @maximum = 729.50
    @minimum = 280

    if amount > 24000
      income = (amount - 24000)/2 - 2615
      income = (7295-income) * 0.1

      if income < @minimum
        Money.new(@minimum)
      elsif (income > @maximum)
        Money.new(@maximum)
      else
        Money.new(income)
      end
      
    else
      Money.new(@maximum)
    end
  end
end

multiple_choice :were_you_or_your_partner_born_on_or_before_6_april_1935? do
  option :yes => :did_you_marry_or_civil_partner_before_5_december_2005?
  option :no => :sorry
end

multiple_choice :did_you_marry_or_civil_partner_before_5_december_2005? do
  option :yes => :whats_the_husbands_income?
  option :no => :whats_the_highest_earners_income?

  calculate :result_strings do
    (responses.last == "yes") ? PhraseList.new(:before_2005) : PhraseList.new(:after_2005)
  end
end

money_question :whats_the_husbands_income? do
  calculate :allowance do
    MarriedCouplesAllowanceAnswer::calculate_allowance(responses.last)
  end

  next_node :done
end

money_question :whats_the_highest_earners_income? do
  calculate :allowance do
    MarriedCouplesAllowanceAnswer::calculate_allowance(responses.last)
  end

  next_node :done
end

outcome :done
outcome :sorry