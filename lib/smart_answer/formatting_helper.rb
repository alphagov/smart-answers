module SmartAnswer
  module FormattingHelper
    include ActionView::Helpers::NumberHelper

    def format_money(amount, pounds_only: false)
      amount = extract_number(amount)
      if show_in_pence?(amount)
        number_to_currency(amount * 100, precision: 0, unit: "p", format: "%n%u")
      else
        ignore_pence_value = pounds_only || amount == amount.round
        number_to_currency(amount, precision: ignore_pence_value ? 0 : 2)
      end
    end

    def format_salary(salary)
      number_to_currency(salary.amount, precision: 0) + " per " + salary.period
    end

    def format_date(date)
      return nil unless date

      date.strftime("%e %B %Y")
    end

  private

    def extract_number(amount)
      BigDecimal(amount.to_s.gsub(/[,\s]/, "")).round(2)
    rescue ArgumentError, TypeError
      amount
    end

    def show_in_pence?(amount)
      amount.is_a?(Numeric) && ((amount < 1) && (amount > -1)) && !amount.round(2).zero?
    end
  end
end
