module SmartAnswer
  module FormattingHelper
    include ActionView::Helpers::NumberHelper

    def format_money(amount)
      number_to_currency(amount, precision: ((amount.to_f == amount.to_f.round) ? 0 : 2))
    end

    def format_salary(salary)
      number_to_currency(salary.amount, precision: 0) + " per " + salary.period
    end

    def format_date(date)
      return nil unless date
      date.strftime('%e %B %Y')
    end
  end
end
