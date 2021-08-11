class VatPaymentDeadlinesFlow < SmartAnswer::Flow
  def define
    content_id "dfa9a5c3-d52e-479c-8505-855f475dc338"
    name "vat-payment-deadlines"
    status :published

    setup do
      self.calculator = SmartAnswer::Calculators::VatPaymentDeadlines.new
    end

    date_question :when_does_your_vat_accounting_period_end? do
      default_day { -1 }

      on_response do |response|
        calculator.period_end_date = response
      end

      validate :error_message do |response|
        response == response.end_of_month
      end

      next_node do
        question :how_do_you_want_to_pay?
      end
    end

    radio :how_do_you_want_to_pay? do
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
          outcome :result_direct_debit
        when "online-telephone-banking"
          outcome :result_online_telephone_banking
        when "online-debit-credit-card"
          outcome :result_online_debit_credit_card
        when "bacs-direct-credit"
          outcome :result_bacs_direct_credit
        when "bank-giro"
          outcome :result_bank_giro
        when "chaps"
          outcome :result_chaps
        when "cheque"
          outcome :result_cheque
        end
      end
    end

    outcome :result_direct_debit
    outcome :result_online_telephone_banking
    outcome :result_online_debit_credit_card
    outcome :result_bacs_direct_credit
    outcome :result_bank_giro
    outcome :result_chaps
    outcome :result_cheque
  end
end
