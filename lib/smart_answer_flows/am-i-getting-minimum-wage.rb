class AmIGettingMinimumWageFlow < SmartAnswer::Flow
  def define
    content_id "111e006d-2b22-4b1f-989a-56bb61355d68"
    name "am-i-getting-minimum-wage"
    status :published

    # Q1
    radio :what_would_you_like_to_check? do
      option "current_payment"
      option "past_payment"

      on_response do |response|
        date = Date.parse("2020-04-01") if response == "past_payment"
        self.calculator = SmartAnswer::Calculators::MinimumWageCalculator.new(date: date)
        self.accommodation_charge = nil
      end

      next_node do |response|
        case response
        when "current_payment"
          question :are_you_an_apprentice?
        when "past_payment"
          question :were_you_an_apprentice?
        end
      end
    end

    # Q3
    value_question :how_old_are_you?, parse: Integer do
      validate do |response|
        calculator.valid_age?(response)
      end

      next_node do |response|
        calculator.age = response
        if calculator.under_school_leaving_age?
          outcome :under_school_leaving_age
        else
          question :how_often_do_you_get_paid?
        end
      end
    end

    append(MinimumWageFlow.build)
  end
end
