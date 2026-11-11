require "working_days"

module SmartAnswer::Calculators
  class VatPaymentDeadlines
    attr_accessor :payment_method, :period_end_date

    def last_payment_date
      case payment_method
      when "direct-debit"
        payment_date = end_of_month_after(period_end_date) + 7.days
        payment_date -= 1 until payment_date.workday?
        2.working_days.before(payment_date)
      when "online-telephone-banking"
        end_of_month_after(period_end_date) + 7.days
      when "online-debit-credit-card", "bacs-direct-credit", "bank-giro"
        2.working_days.before(funds_received_by)
      else
        raise ArgumentError, "Invalid payment method"
      end
    end

    def funds_received_by
      case payment_method
      when "direct-debit"
        3.working_days.after(end_of_month_after(period_end_date) + 7.days)
      when "online-telephone-banking"
        # This doesn't really apply to online banking, but the flow expects this
        # to always return a date.
        last_payment_date
      when "online-debit-credit-card", "bacs-direct-credit", "bank-giro"
        # Select previous working day if not a work_day
        0.working_days.before(end_of_month_after(period_end_date) + 7.days)
      else
        raise ArgumentError, "Invalid payment method"
      end
    end

  private

    def end_of_month_after(date)
      1.month.since(date).end_of_month
    end
  end
end
