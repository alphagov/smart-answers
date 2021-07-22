class MaternityPaternityCalculatorFlow < SmartAnswer::Flow
  class SharedAdoptionMaternityPaternityFlow < SmartAnswer::Flow
    def define
      payment_options = SmartAnswer::Calculators::MaternityPayCalculator.payment_options

      # This question is being used in:
      # QM8 in MaternityCalculatorFlow
      # QP13 in PaternityCalculatorFlow
      # QA10 in AdoptionCalculatorFlow
      radio :how_many_payments_weekly? do
        payment_options[:weekly].each_key do |payment_option|
          option payment_option
        end

        on_response do |response|
          calculator.payment_option = response
        end

        next_node do
          case calculator.leave_type
          when "adoption"
            question :how_do_you_want_the_sap_calculated?
          when "maternity"
            question :how_do_you_want_the_smp_calculated?
          else
            question :how_do_you_want_the_spp_calculated?
          end
        end
      end

      # This question is being used in:
      # QM8 in MaternityCalculatorFlow
      # QP13 in PaternityCalculatorFlow
      # QA10 in AdoptionCalculatorFlow
      radio :how_many_payments_every_2_weeks? do
        payment_options[:every_2_weeks].each_key do |payment_option|
          option payment_option
        end

        on_response do |response|
          calculator.payment_option = response
        end

        next_node do
          case calculator.leave_type
          when "adoption"
            question :how_do_you_want_the_sap_calculated?
          when "maternity"
            question :how_do_you_want_the_smp_calculated?
          else
            question :how_do_you_want_the_spp_calculated?
          end
        end
      end

      # This question is being used in:
      # QM8 in MaternityCalculatorFlow
      # QP13 in PaternityCalculatorFlow
      # QA10 in AdoptionCalculatorFlow
      radio :how_many_payments_every_4_weeks? do
        payment_options[:every_4_weeks].each_key do |payment_option|
          option payment_option
        end

        on_response do |response|
          calculator.payment_option = response
        end

        next_node do
          case calculator.leave_type
          when "adoption"
            question :how_do_you_want_the_sap_calculated?
          when "maternity"
            question :how_do_you_want_the_smp_calculated?
          else
            question :how_do_you_want_the_spp_calculated?
          end
        end
      end

      # This question is being used in:
      # QM8 in MaternityCalculatorFlow
      # QP13 in PaternityCalculatorFlow
      # QA10 in AdoptionCalculatorFlow
      radio :how_many_payments_monthly? do
        payment_options[:monthly].each_key do |payment_option|
          option payment_option
        end

        on_response do |response|
          calculator.payment_option = response
        end

        next_node do
          case calculator.leave_type
          when "adoption"
            question :how_do_you_want_the_sap_calculated?
          when "maternity"
            question :how_do_you_want_the_smp_calculated?
          else
            question :how_do_you_want_the_spp_calculated?
          end
        end
      end
    end
  end
end
