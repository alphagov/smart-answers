module MaternityCalculatorHelper
  def check_smp_calculation(dates_and_pay)
    assert_state_variable :pay_dates_and_pay, dates_and_pay.map { |date, pay|
      "#{date}|#{pay}"
    }.join("\n")
  end
end
