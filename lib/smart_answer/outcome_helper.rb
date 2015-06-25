module SmartAnswer
  module OutcomeHelper
    def format_money(amount)
      number_to_currency(amount, precision: ((amount.to_f == amount.to_f.round) ? 0 : 2))
    end
  end
end
