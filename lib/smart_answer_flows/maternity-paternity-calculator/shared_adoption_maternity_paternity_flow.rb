module SmartAnswer
  class SharedAdoptionMaternityPaternityFlow < Flow
    def define
      payment_options_weekly = Calculators::MaternityPayCalculator.payment_options("weekly")
      payment_options_every_2_weeks = Calculators::MaternityPayCalculator.payment_options("every_2_weeks")
      payment_options_every_4_weeks = Calculators::MaternityPayCalculator.payment_options("every_4_weeks")
      payment_options_monthly = Calculators::MaternityPayCalculator.payment_options("monthly")

      # This question is being used in:
      # QM9 in MaternityCalculatorFlow
      # QP13 in PaternityCalculatorFlow
      # QA10 in AdoptionCalculatorFlow
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
          if calculator.is_a?(Calculators::AdoptionPayCalculator)
            question :how_do_you_want_the_sap_calculated?
          elsif calculator.is_a?(Calculators::MaternityPayCalculator)
            question :how_do_you_want_the_smp_calculated?
          elsif calculator.is_a?(Calculators::PaternityPayCalculator)
            question :how_do_you_want_the_spp_calculated?
          end
        end
      end

      # This question is being used in:
      # QM9 in MaternityCalculatorFlow
      # QP13 in PaternityCalculatorFlow
      # QA10 in AdoptionCalculatorFlow
      multiple_choice :how_many_payments_every_2_weeks? do
        payment_options_every_2_weeks.keys.each do |payment_option|
          option payment_option
        end

        precalculate :payment_options_every_2_weeks do
          payment_options_every_2_weeks
        end

        on_response do |response|
          calculator.payment_option = response
        end

        next_node do
          if calculator.is_a?(Calculators::AdoptionPayCalculator)
            question :how_do_you_want_the_sap_calculated?
          elsif calculator.is_a?(Calculators::MaternityPayCalculator)
            question :how_do_you_want_the_smp_calculated?
          elsif calculator.is_a?(Calculators::PaternityPayCalculator)
            question :how_do_you_want_the_spp_calculated?
          end
        end
      end

      # This question is being used in:
      # QM9 in MaternityCalculatorFlow
      # QP13 in PaternityCalculatorFlow
      # QA10 in AdoptionCalculatorFlow
      multiple_choice :how_many_payments_every_4_weeks? do
        payment_options_every_4_weeks.keys.each do |payment_option|
          option payment_option
        end

        precalculate :payment_options_every_4_weeks do
          payment_options_every_4_weeks
        end

        on_response do |response|
          calculator.payment_option = response
        end

        next_node do
          if calculator.is_a?(Calculators::AdoptionPayCalculator)
            question :how_do_you_want_the_sap_calculated?
          elsif calculator.is_a?(Calculators::MaternityPayCalculator)
            question :how_do_you_want_the_smp_calculated?
          elsif calculator.is_a?(Calculators::PaternityPayCalculator)
            question :how_do_you_want_the_spp_calculated?
          end
        end
      end

      # This question is being used in:
      # QM9 in MaternityCalculatorFlow
      # QP13 in PaternityCalculatorFlow
      # QA10 in AdoptionCalculatorFlow
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
          if calculator.is_a?(Calculators::AdoptionPayCalculator)
            question :how_do_you_want_the_sap_calculated?
          elsif calculator.is_a?(Calculators::MaternityPayCalculator)
            question :how_do_you_want_the_smp_calculated?
          elsif calculator.is_a?(Calculators::PaternityPayCalculator)
            question :how_do_you_want_the_spp_calculated?
          end
        end
      end
    end
  end
end
