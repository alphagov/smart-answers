module SmartAnswer
  class VatPaymentDeadlinesFlow < Flow
    def define
      content_id "dfa9a5c3-d52e-479c-8505-855f475dc338"
      name 'vat-payment-deadlines'
      status :published
      satisfies_need "100624"

      date_question :when_does_your_vat_accounting_period_end? do
        default_day { -1 }
        next_node :how_do_you_want_to_pay?

        calculate :period_end_date do |response|
          date = response
          raise InvalidResponse unless date == date.end_of_month
          date
        end
      end

      multiple_choice :how_do_you_want_to_pay? do
        option 'direct-debit': :result_direct_debit
        option 'online-telephone-banking': :result_online_telephone_banking
        option 'online-debit-credit-card': :result_online_debit_credit_card
        option 'bacs-direct-credit': :result_bacs_direct_credit
        option 'bank-giro': :result_bank_giro
        option 'chaps': :result_chaps
        option 'cheque': :result_cheque

        calculate :calculator do |response|
          Calculators::VatPaymentDeadlines.new(period_end_date, response)
        end

        calculate :last_payment_date do
          calculator.last_payment_date.strftime("%e %B %Y").strip
        end
        calculate :funds_received_by do
          calculator.funds_received_by.strftime("%e %B %Y").strip
        end
      end

      outcome :result_direct_debit do
        precalculate(:last_dd_setup_date) { last_payment_date }
        precalculate(:funds_taken) { funds_received_by }
      end
      outcome :result_online_telephone_banking
      outcome :result_online_debit_credit_card
      outcome :result_bacs_direct_credit
      outcome :result_bank_giro
      outcome :result_chaps
      outcome :result_cheque do
        precalculate(:last_posting_date) { last_payment_date }
        precalculate(:funds_cleared_by) { funds_received_by }
      end
    end
  end
end
