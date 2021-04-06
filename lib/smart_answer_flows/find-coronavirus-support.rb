module SmartAnswer
  class FindCoronavirusSupportFlow < Flow
    def define
      name "find-coronavirus-support"
      content_id "d67f2c92-d0f0-438b-9c81-c0059dd71baf"
      status :published
      response_store :session
      use_escape_button true
      hide_previous_answers_on_results_page true

      # ======================================================================
      # What do you need help with because of coronavirus?
      # ======================================================================
      checkbox_question :need_help_with do
        option :feeling_unsafe
        option :paying_bills
        option :getting_food
        option :being_unemployed
        option :going_to_work
        option :self_isolating
        option :somewhere_to_live
        option :mental_health
        none_option

        on_response do |response|
          self.calculator = Calculators::FindCoronavirusSupportCalculator.new
          calculator.need_help_with = response
        end

        next_node do
          question calculator.next_question(:need_help_with)
        end
      end

      # ======================================================================
      # Do you feel safe where you live?
      # ======================================================================
      radio :feel_unsafe do
        option :yes
        option :concerned_about_others
        option :no
        option :not_sure

        on_response do |response|
          calculator.feel_unsafe = response
        end

        next_node do
          question calculator.next_question(:feel_unsafe)
        end
      end

      # ======================================================================
      # Are you finding it hard to afford rent, your mortgage or bills?
      # ======================================================================
      radio :afford_rent_mortgage_bills do
        option :yes
        option :no
        option :not_sure

        on_response do |response|
          calculator.afford_rent_mortgage_bills = response
        end

        next_node do
          question calculator.next_question(:afford_rent_mortgage_bills)
        end
      end

      # ======================================================================
      # Are you finding it hard to afford food?
      # ======================================================================
      radio :afford_food do
        option :yes
        option :no
        option :not_sure

        on_response do |response|
          calculator.afford_food = response
        end

        next_node do
          question :get_food
        end
      end

      # ======================================================================
      # Are your able to get food?
      # ======================================================================
      radio :get_food do
        option :yes
        option :no
        option :not_sure

        on_response do |response|
          calculator.get_food = response
        end

        next_node do
          question calculator.next_question(:get_food)
        end
      end

      # ======================================================================
      # Are you self-employed or a sole trader?
      # ======================================================================
      radio :self_employed do
        option :yes
        option :no
        option :not_sure

        on_response do |response|
          calculator.self_employed = response
        end

        next_node do
          if calculator.self_employed == "yes"
            question calculator.next_question(:have_you_been_made_unemployed)
          else
            question :have_you_been_made_unemployed
          end
        end
      end

      # ======================================================================
      # Have you been told to stop working?
      # ======================================================================
      radio :have_you_been_made_unemployed do
        option :yes_i_have_been_made_unemployed
        option :yes_i_have_been_put_on_furlough
        option :no
        option :not_sure

        on_response do |response|
          calculator.have_you_been_made_unemployed = response
        end

        next_node do
          question calculator.next_question(:have_you_been_made_unemployed)
        end
      end

      # ======================================================================
      # Are you worried about going in to work?
      # ======================================================================
      radio :worried_about_work do
        option :yes
        option :no
        option :not_sure

        on_response do |response|
          calculator.worried_about_work = response
        end

        next_node do
          question calculator.next_question(:worried_about_work)
        end
      end

      # ======================================================================
      # Are you worried about self-isolating?
      # ======================================================================
      radio :worried_about_self_isolating do
        option :yes
        option :no

        on_response do |response|
          calculator.worried_about_self_isolating = response
        end

        next_node do
          question calculator.next_question(:worried_about_self_isolating)
        end
      end

      # ======================================================================
      # Do you have somewhere to live?
      # ======================================================================
      radio :have_somewhere_to_live do
        option :yes
        option :yes_but_i_might_lose_it
        option :no
        option :not_sure

        on_response do |response|
          calculator.have_somewhere_to_live = response
        end

        next_node do
          question :have_you_been_evicted
        end
      end

      # ======================================================================
      # Have you been evicted?
      # ======================================================================
      radio :have_you_been_evicted do
        option :yes
        option :yes_i_might_be_soon
        option :no
        option :not_sure

        on_response do |response|
          calculator.have_you_been_evicted = response
        end

        next_node do
          question calculator.next_question(:have_you_been_evicted)
        end
      end

      # ======================================================================
      # Are you worries about your mental health or someone else's mental health?
      # ======================================================================
      radio :mental_health_worries do
        option :yes
        option :no
        option :not_sure

        on_response do |response|
          calculator.mental_health_worries = response
        end

        next_node do
          question :nation
        end
      end

      # ======================================================================
      # Where do you live?
      # ======================================================================
      radio :nation do
        option :england
        option :scotland
        option :wales
        option :northern_ireland

        on_response do |response|
          calculator.nation = response
        end

        next_node do
          outcome :results
        end
      end

      # ======================================================================
      # Results
      # ======================================================================
      outcome :results
    end
  end
end
