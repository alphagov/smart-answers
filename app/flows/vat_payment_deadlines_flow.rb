class VatPaymentDeadlinesFlow < SmartAnswer::Flow
  def define
    content_id "dfa9a5c3-d52e-479c-8505-855f475dc338"
    name "vat-payment-deadlines"
    status :published

    setup do
      self.calculator = SmartAnswer::Calculators::VatPaymentDeadlines.new
    end

    date_question :vat_accounting_period_end do
      default_day { -1 }

      on_response do |response|
        calculator.period_end_date = response
      end

      validate :error_message do |response|
        response == response.end_of_month
      end

      next_node do
        question :payment_method
      end
    end

    radio :payment_method do
      option "direct-debit"
      option "online-telephone-banking"
      option "online-debit-credit-card"
      option "bacs-direct-credit"
      option "bank-giro"
      option "chaps"
      option "cheque"

      on_response do |response|
        calculator.payment_method = response
      end

      next_node do |response|
        case response
        when "direct-debit"
          outcome :direct_debit
        when "online-telephone-banking"
          outcome :online_telephone_banking
        when "online-debit-credit-card"
          outcome :online_debit_credit_card
        when "bacs-direct-credit"
          outcome :bacs_direct_credit
        when "bank-giro"
          outcome :bank_giro
        when "chaps"
          outcome :chaps
        when "cheque"
          outcome :cheque
        end
      end
    end

    outcome :direct_debit
    outcome :online_telephone_banking
    outcome :online_debit_credit_card
    outcome :bacs_direct_credit
    outcome :bank_giro
    outcome :chaps
    outcome :cheque
  end
end
