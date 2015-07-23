module SmartAnswer
  module OutcomeHelper
    def format_money(amount)
      number_to_currency(amount, precision: ((amount.to_f == amount.to_f.round) ? 0 : 2))
    end

    def format_date(date)
      return nil unless date
      date.strftime('%e %B %Y')
    end
  end
end
