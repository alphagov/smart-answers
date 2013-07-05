status :draft
satisfies_need 2834

date_question :when_does_your_vat_accounting_period_end? do
  next_node :how_do_you_want_to_pay?

  calculate :period_end_date do
    Date.parse(responses.last)
  end
end

multiple_choice :how_do_you_want_to_pay? do
  option :'direct-debit' => :result_direct_debit
  option :'online-telephone-banking' => :result_online_telephone_banking
  option :'online-debit-credit-card' => :result_online_debit_credit_card
  option :'bacs-direct-credit' => :result_bacs_direct_credit
  option :'bank-giro' => :result_bank_giro
  option :'chaps' => :result_chaps
  option :'cheque' => :result_cheque
end

outcome :result_direct_debit
outcome :result_online_telephone_banking do
  precalculate :last_payment_date do
    (period_end_date + 1.month + 7.days).strftime("%e %B %Y")
  end
end
outcome :result_online_debit_credit_card
outcome :result_bacs_direct_credit
outcome :result_bank_giro
outcome :result_chaps
outcome :result_cheque
