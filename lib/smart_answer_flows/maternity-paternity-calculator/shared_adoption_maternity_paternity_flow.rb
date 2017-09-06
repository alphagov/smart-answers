module SmartAnswer
  class SharedAdoptionMaternityPaternityFlow < Flow
    def define
      payment_options_weekly = Calculators::MaternityPaternityCalculator.payment_options("weekly")
      payment_options_monthly = Calculators::MaternityPaternityCalculator.payment_options("monthly")

      # This question is being used in:
      # QM9 in MaternityCalculatorFlow
      multiple_choice :how_many_payments_weekly? do
        payment_options_weekly.keys.each do |payment_option|
          option payment_option
        end

        precalculate :payment_options_weekly do
          payment_options_weekly
        end

        on_response do |response|
          calculator.payment_option = response
        end

        next_node do
          question :how_do_you_want_the_smp_calculated?
        end
      end

      # This question is being used in:
      # QM9 in MaternityCalculatorFlow
      multiple_choice :how_many_payments_monthly? do
        payment_options_monthly.keys.each do |payment_option|
          option payment_option
        end

        precalculate :payment_options_monthly do
          payment_options_monthly
        end

        on_response do |response|
          calculator.payment_option = response
        end

        next_node do
          question :how_do_you_want_the_smp_calculated?
        end
      end
    end
  end
end
