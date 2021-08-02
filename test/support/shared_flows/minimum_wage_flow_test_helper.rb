module MinimumWageFlowTestHelper
  def test_shared_minimum_wage_flow_questions
    context "question: what_would_you_like_to_check?" do
      setup { testing_node :what_would_you_like_to_check? }

      should "render question" do
        assert_rendered_question
      end
    end

    context "next_node" do
      should "have a next node of are_you_an_apprentice? for a 'current_payment' response" do
        assert_next_node :are_you_an_apprentice?, for_response: "current_payment"
      end

      should "have a next node of were_you_an_apprentice? for a 'past_payment' response" do
        assert_next_node :were_you_an_apprentice?, for_response: "past_payment"
      end
    end

    context "question: are_you_an_apprentice?" do
      setup do
        testing_node :are_you_an_apprentice?
        add_responses what_would_you_like_to_check?: "current_payment"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of how_old_are_you? for a 'not_an_apprentice' response" do
          assert_next_node :how_old_are_you?, for_response: "not_an_apprentice"
        end

        should "have a next node of how_old_are_you? for a 'apprentice_over_19_second_year_onwards' response" do
          assert_next_node :how_old_are_you?, for_response: "apprentice_over_19_second_year_onwards"
        end

        should "have a next node of how_often_do_you_get_paid? for a 'apprentice_under_19' response" do
          assert_next_node :how_often_do_you_get_paid?, for_response: "apprentice_under_19"
        end

        should "have a next node of how_often_do_you_get_paid? for a 'apprentice_over_19_first_year' response" do
          assert_next_node :how_often_do_you_get_paid?, for_response: "apprentice_over_19_first_year"
        end
      end
    end

    context "question: were_you_an_apprentice?" do
      setup do
        testing_node :were_you_an_apprentice?
        add_responses what_would_you_like_to_check?: "past_payment"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of how_old_were_you? for a 'no' response" do
          assert_next_node :how_old_were_you?, for_response: "no"
        end

        should "have a next node of how_often_did_you_get_paid? for a 'apprentice_under_19' response" do
          assert_next_node :how_often_did_you_get_paid?, for_response: "apprentice_under_19"
        end

        should "have a next node of how_often_did_you_get_paid? for a 'apprentice_over_19' response" do
          assert_next_node :how_often_did_you_get_paid?, for_response: "apprentice_over_19"
        end
      end
    end

    context "question: how_old_are_you?" do
      setup do
        testing_node :how_old_are_you?
        add_responses what_would_you_like_to_check?: "current_payment",
                      are_you_an_apprentice?: "not_an_apprentice"
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for a valid age" do
          assert_valid_response "50"
        end

        should "be invalid for a invalid age" do
          assert_invalid_response "-1"
        end
      end

      context "next_node" do
        should "have a next node of under_school_leaving_age for an age under 16 " do
          assert_next_node :under_school_leaving_age, for_response: "15"
        end

        should "have a next node of how_often_do_you_get_paid? for an age 16 or over" do
          assert_next_node :how_often_do_you_get_paid?, for_response: "16"
        end
      end
    end

    context "question: how_old_were_you?" do
      setup do
        testing_node :how_old_were_you?
        add_responses what_would_you_like_to_check?: "past_payment",
                      were_you_an_apprentice?: "no"
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for a valid age" do
          assert_valid_response "50"
        end

        should "be invalid for a invalid age" do
          assert_invalid_response "-1"
        end
      end

      context "next_node" do
        should "have a next node of under_school_leaving_age_past for an age under 16" do
          assert_next_node :under_school_leaving_age_past, for_response: "15"
        end

        should "have a next node of how_often_did_you_get_paid? for an age 16 or over" do
          assert_next_node :how_often_did_you_get_paid?, for_response: "16"
        end
      end
    end

    context "question: how_often_do_you_get_paid?" do
      setup do
        testing_node :how_often_do_you_get_paid?
        add_responses what_would_you_like_to_check?: "current_payment",
                      are_you_an_apprentice?: "not_an_apprentice",
                      how_old_are_you?: "16"
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for an valid pay frequency" do
          assert_valid_response "15"
        end

        should "be invalid for an invalid pay frequency" do
          assert_invalid_response "0"
        end
      end

      context "next_node" do
        should "have a next node of how_many_hours_do_you_work?" do
          assert_next_node :how_many_hours_do_you_work?, for_response: "15"
        end
      end
    end

    context "question: how_often_did_you_get_paid?" do
      setup do
        testing_node :how_often_did_you_get_paid?
        add_responses what_would_you_like_to_check?: "past_payment",
                      were_you_an_apprentice?: "no",
                      how_old_were_you?: "16"
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for an valid pay frequency" do
          assert_valid_response "15"
        end

        should "be invalid for an invalid pay frequency" do
          assert_invalid_response "0"
        end
      end

      context "next_node" do
        should "have a next node of how_many_hours_did_you_work?" do
          assert_next_node :how_many_hours_did_you_work?, for_response: "15"
        end
      end
    end

    context "question: how_many_hours_do_you_work?" do
      setup do
        testing_node :how_many_hours_do_you_work?
        add_responses what_would_you_like_to_check?: "current_payment",
                      are_you_an_apprentice?: "not_an_apprentice",
                      how_old_are_you?: "16",
                      how_often_do_you_get_paid?: "15"
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for valid hours worked" do
          assert_valid_response "5.5"
        end

        should "be invalid for invalid hours worked" do
          assert_invalid_response "0"
        end
      end

      context "next_node" do
        should "have a next node of how_much_are_you_paid_during_pay_period?" do
          assert_next_node :how_much_are_you_paid_during_pay_period?, for_response: "5.5"
        end
      end
    end

    context "question: how_many_hours_did_you_work?" do
      setup do
        testing_node :how_many_hours_did_you_work?
        add_responses what_would_you_like_to_check?: "past_payment",
                      were_you_an_apprentice?: "no",
                      how_old_were_you?: "16",
                      how_often_did_you_get_paid?: "15"
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for valid hours worked" do
          assert_valid_response "5.5"
        end

        should "be invalid for invalid hours worked" do
          assert_invalid_response "0"
        end
      end

      context "next_node" do
        should "have a next node of how_much_were_you_paid_during_pay_period?" do
          assert_next_node :how_much_were_you_paid_during_pay_period?, for_response: "5.5"
        end
      end
    end

    context "question: how_much_are_you_paid_during_pay_period?" do
      setup do
        testing_node :how_much_are_you_paid_during_pay_period?
        add_responses what_would_you_like_to_check?: "current_payment",
                      are_you_an_apprentice?: "not_an_apprentice",
                      how_old_are_you?: "16",
                      how_often_do_you_get_paid?: "15",
                      how_many_hours_do_you_work?: "5"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of is_provided_with_accommodation?" do
          assert_next_node :is_provided_with_accommodation?, for_response: "100"
        end
      end
    end

    context "question: how_much_were_you_paid_during_pay_period?" do
      setup do
        testing_node :how_much_were_you_paid_during_pay_period?
        add_responses what_would_you_like_to_check?: "past_payment",
                      were_you_an_apprentice?: "no",
                      how_old_were_you?: "16",
                      how_often_did_you_get_paid?: "15",
                      how_many_hours_did_you_work?: "5"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of was_provided_with_accommodation?" do
          assert_next_node :was_provided_with_accommodation?, for_response: "100"
        end
      end
    end

    context "question: is_provided_with_accommodation?" do
      setup do
        testing_node :is_provided_with_accommodation?
        add_responses what_would_you_like_to_check?: "current_payment",
                      are_you_an_apprentice?: "not_an_apprentice",
                      how_old_are_you?: "16",
                      how_often_do_you_get_paid?: "15",
                      how_many_hours_do_you_work?: "5",
                      how_much_are_you_paid_during_pay_period?: "100"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of current_accommodation_usage? for a response of 'yes_free'" do
          assert_next_node :current_accommodation_usage?, for_response: "yes_free"
        end

        should "have a next node of current_accommodation_charge? for a response of 'yes_charged'" do
          assert_next_node :current_accommodation_charge?, for_response: "yes_charged"
        end

        should "have a next node of does_employer_charge_for_job_requirements? for a response of 'no'" do
          assert_next_node :does_employer_charge_for_job_requirements?, for_response: "no"
        end
      end
    end

    context "question: was_provided_with_accommodation?" do
      setup do
        testing_node :was_provided_with_accommodation?
        add_responses what_would_you_like_to_check?: "past_payment",
                      were_you_an_apprentice?: "no",
                      how_old_were_you?: "16",
                      how_often_did_you_get_paid?: "15",
                      how_many_hours_did_you_work?: "5",
                      how_much_were_you_paid_during_pay_period?: "100"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of past_accommodation_usage? for a response of 'yes_free'" do
          assert_next_node :past_accommodation_usage?, for_response: "yes_free"
        end

        should "have a next node of past_accommodation_charge? for a response of 'yes_charged'" do
          assert_next_node :past_accommodation_charge?, for_response: "yes_charged"
        end

        should "have a next node of did_employer_charge_for_job_requirements? for a response of 'no'" do
          assert_next_node :did_employer_charge_for_job_requirements?, for_response: "no"
        end
      end
    end

    context "question: current_accommodation_charge?" do
      setup do
        testing_node :current_accommodation_charge?
        add_responses what_would_you_like_to_check?: "current_payment",
                      are_you_an_apprentice?: "not_an_apprentice",
                      how_old_are_you?: "16",
                      how_often_do_you_get_paid?: "15",
                      how_many_hours_do_you_work?: "5",
                      how_much_are_you_paid_during_pay_period?: "100",
                      is_provided_with_accommodation?: "yes_charged"
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for a valid accomodation charge" do
          assert_valid_response "100"
        end

        should "be invalid for an invalid accomodation charge" do
          assert_invalid_response "0"
        end
      end

      context "next_node" do
        should "have a next node of current_accommodation_usage?" do
          assert_next_node :current_accommodation_usage?, for_response: "100"
        end
      end
    end

    context "question: past_accommodation_charge?" do
      setup do
        testing_node :past_accommodation_charge?
        add_responses what_would_you_like_to_check?: "past_payment",
                      were_you_an_apprentice?: "no",
                      how_old_were_you?: "16",
                      how_often_did_you_get_paid?: "15",
                      how_many_hours_did_you_work?: "5",
                      how_much_were_you_paid_during_pay_period?: "100",
                      was_provided_with_accommodation?: "yes_charged"
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for a valid accomodation charge" do
          assert_valid_response "100"
        end

        should "be invalid for an invalid accomodation charge" do
          assert_invalid_response "0"
        end
      end

      context "next_node" do
        should "have a next node of past_accommodation_usage?" do
          assert_next_node :past_accommodation_usage?, for_response: "100"
        end
      end
    end

    context "question: current_accommodation_usage?" do
      setup do
        testing_node :current_accommodation_usage?
        add_responses what_would_you_like_to_check?: "current_payment",
                      are_you_an_apprentice?: "not_an_apprentice",
                      how_old_are_you?: "16",
                      how_often_do_you_get_paid?: "15",
                      how_many_hours_do_you_work?: "5",
                      how_much_are_you_paid_during_pay_period?: "100",
                      is_provided_with_accommodation?: "yes_free"
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for a valid accomodation usage" do
          assert_valid_response "5"
        end

        should "be invalid for an invalid accomodation usage" do
          assert_invalid_response "8"
        end
      end

      context "next_node" do
        should "have a next node of does_employer_charge_for_job_requirements?" do
          assert_next_node :does_employer_charge_for_job_requirements?, for_response: "5"
        end
      end
    end

    context "question: past_accommodation_usage?" do
      setup do
        testing_node :past_accommodation_usage?
        add_responses what_would_you_like_to_check?: "past_payment",
                      were_you_an_apprentice?: "no",
                      how_old_were_you?: "16",
                      how_often_did_you_get_paid?: "15",
                      how_many_hours_did_you_work?: "5",
                      how_much_were_you_paid_during_pay_period?: "100",
                      was_provided_with_accommodation?: "yes_free"
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for a valid accomodation usage" do
          assert_valid_response "5"
        end

        should "be invalid for an invalid accomodation usage" do
          assert_invalid_response "8"
        end
      end

      context "next_node" do
        should "have a next node of did_employer_charge_for_job_requirements?" do
          assert_next_node :did_employer_charge_for_job_requirements?, for_response: "5"
        end
      end
    end

    context "question: does_employer_charge_for_job_requirements?" do
      setup do
        testing_node :does_employer_charge_for_job_requirements?
        add_responses what_would_you_like_to_check?: "current_payment",
                      are_you_an_apprentice?: "not_an_apprentice",
                      how_old_are_you?: "16",
                      how_often_do_you_get_paid?: "15",
                      how_many_hours_do_you_work?: "5",
                      how_much_are_you_paid_during_pay_period?: "100",
                      is_provided_with_accommodation?: "no"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of current_additional_work_outside_shift?" do
          assert_next_node :current_additional_work_outside_shift?, for_response: "yes"
        end
      end
    end

    context "question: did_employer_charge_for_job_requirements?" do
      setup do
        testing_node :did_employer_charge_for_job_requirements?
        add_responses what_would_you_like_to_check?: "past_payment",
                      were_you_an_apprentice?: "no",
                      how_old_were_you?: "16",
                      how_often_did_you_get_paid?: "15",
                      how_many_hours_did_you_work?: "5",
                      how_much_were_you_paid_during_pay_period?: "100",
                      was_provided_with_accommodation?: "no"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of past_additional_work_outside_shift?" do
          assert_next_node :past_additional_work_outside_shift?, for_response: "yes"
        end
      end
    end

    context "question: current_additional_work_outside_shift?" do
      setup do
        testing_node :current_additional_work_outside_shift?
        add_responses what_would_you_like_to_check?: "current_payment",
                      are_you_an_apprentice?: "not_an_apprentice",
                      how_old_are_you?: "16",
                      how_often_do_you_get_paid?: "15",
                      how_many_hours_do_you_work?: "5",
                      how_much_are_you_paid_during_pay_period?: "100",
                      is_provided_with_accommodation?: "no",
                      does_employer_charge_for_job_requirements?: "yes"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of current_paid_for_work_outside_shift? for a 'yes' response" do
          assert_next_node :current_paid_for_work_outside_shift?, for_response: "yes"
        end

        context "when a 'no' response is given" do
          setup { add_response "no" }

          should "have a next node of current_payment_above for someone earning at least minimum wage" do
            # high number to be above minimum wage
            add_responses how_much_are_you_paid_during_pay_period?: "1000000"
            assert_next_node :current_payment_above
          end

          should "have a next node of current_payment_below for someone earning below minimum wage" do
            # low number to be above minimum wage
            add_responses how_much_are_you_paid_during_pay_period?: "1"
            assert_next_node :current_payment_below
          end
        end
      end
    end

    context "question: past_additional_work_outside_shift?" do
      setup do
        testing_node :past_additional_work_outside_shift?
        add_responses what_would_you_like_to_check?: "past_payment",
                      were_you_an_apprentice?: "no",
                      how_old_were_you?: "16",
                      how_often_did_you_get_paid?: "15",
                      how_many_hours_did_you_work?: "5",
                      how_much_were_you_paid_during_pay_period?: "100",
                      was_provided_with_accommodation?: "no",
                      did_employer_charge_for_job_requirements?: "yes"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of past_paid_for_work_outside_shift? for a 'yes' response" do
          assert_next_node :past_paid_for_work_outside_shift?, for_response: "yes"
        end

        context "when a 'no' response is given" do
          setup { add_response "no" }

          should "have a next node of past_payment_above for someone earning at least minimum wage" do
            # high number to be above minimum wage
            add_responses how_much_were_you_paid_during_pay_period?: "1000000"
            assert_next_node :past_payment_above
          end

          should "have a next node of past_payment_below for someone earning below minimum wage" do
            # low number to be above minimum wage
            add_responses how_much_were_you_paid_during_pay_period?: "1"
            assert_next_node :past_payment_below
          end
        end
      end
    end

    context "question: current_paid_for_work_outside_shift?" do
      setup do
        testing_node :current_paid_for_work_outside_shift?
        add_responses what_would_you_like_to_check?: "current_payment",
                      are_you_an_apprentice?: "not_an_apprentice",
                      how_old_are_you?: "16",
                      how_often_do_you_get_paid?: "15",
                      how_many_hours_do_you_work?: "5",
                      how_much_are_you_paid_during_pay_period?: "100",
                      is_provided_with_accommodation?: "no",
                      does_employer_charge_for_job_requirements?: "yes",
                      current_additional_work_outside_shift?: "yes"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of current_payment_above for someone earning at least minimum wage" do
          # high number to be above minimum wage
          add_responses how_much_are_you_paid_during_pay_period?: "1000000"
          assert_next_node :current_payment_above, for_response: "yes"
        end

        should "have a next node of current_payment_below for someone earning below minimum wage" do
          # low number to be above minimum wage
          add_responses how_much_are_you_paid_during_pay_period?: "1"
          assert_next_node :current_payment_below, for_response: "yes"
        end
      end
    end

    context "question: past_paid_for_work_outside_shift?" do
      setup do
        testing_node :past_paid_for_work_outside_shift?
        add_responses what_would_you_like_to_check?: "past_payment",
                      were_you_an_apprentice?: "no",
                      how_old_were_you?: "16",
                      how_often_did_you_get_paid?: "15",
                      how_many_hours_did_you_work?: "5",
                      how_much_were_you_paid_during_pay_period?: "100",
                      was_provided_with_accommodation?: "no",
                      did_employer_charge_for_job_requirements?: "yes",
                      past_additional_work_outside_shift?: "yes"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of past_payment_above for someone earning at least minimum wage" do
          # high number to be above minimum wage
          add_responses how_much_were_you_paid_during_pay_period?: "1000000"
          assert_next_node :past_payment_above, for_response: "yes"
        end

        should "have a next node of past_payment_below for someone earning below minimum wage" do
          # low number to be above minimum wage
          add_responses how_much_were_you_paid_during_pay_period?: "1"
          assert_next_node :past_payment_below, for_response: "yes"
        end
      end
    end
  end
end
