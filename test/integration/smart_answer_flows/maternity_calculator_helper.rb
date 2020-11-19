module MaternityCalculatorHelper
  def check_smp_calculation(dates_and_pay)
    assert_equal current_state.calculator.pay_dates_and_pay,
                 dates_and_pay.map { |date, pay|
                   "#{date}|#{pay}"
                 }.join("\n")
  end
end
