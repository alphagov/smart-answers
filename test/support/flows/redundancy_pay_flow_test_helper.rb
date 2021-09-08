module RedundancyPayFlowTestHelper
  def test_shared_redundancy_pay_flow_questions
    context "question: date_of_redundancy?" do
      setup do
        testing_node :date_of_redundancy?
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for a valid redundancy date" do
          assert_valid_response 3.years.ago.strftime("%Y-%m-%d")
        end

        should "be invalid for an invalid redundancy date" do
          assert_invalid_response 5.years.ago.strftime("%Y-%m-%d")
        end
      end

      context "next node" do
        should "have a next node of age_of_employee?" do
          assert_next_node :age_of_employee?, for_response: 3.years.ago.strftime("%Y-%m-%d")
        end
      end
    end

    context "question: age_of_employee?" do
      setup do
        testing_node :age_of_employee?
        add_responses date_of_redundancy?: 3.years.ago.strftime("%Y-%m-%d")
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for an employee age between 16 to 100" do
          assert_valid_response "16"
        end

        should "be invalid for an employee age below 16" do
          assert_invalid_response "15"
        end
      end

      context "next_node" do
        should "have a next node of years_employed?" do
          assert_next_node :years_employed?, for_response: "16"
        end
      end
    end

    context "question: years_employed?" do
      setup do
        testing_node :years_employed?
        add_responses date_of_redundancy?: 3.years.ago.strftime("%Y-%m-%d"),
                      age_of_employee?: "16"
      end

      should "render question" do
        assert_rendered_question
      end

      context "validation" do
        should "be valid for a valid number of years employed" do
          assert_valid_response "1"
        end

        should "be invalid for an invalid number of years employed" do
          assert_invalid_response "2"
        end
      end

      context "next_node" do
        should "have a next node of done_no_statutory if number of years employed is less than 2" do
          assert_next_node :done_no_statutory, for_response: "1"
        end

        should "have a next node of weekly_pay_before_tax? if number of years employed is greater than 2" do
          add_responses age_of_employee?: "17"
          assert_next_node :weekly_pay_before_tax?, for_response: "2"
        end
      end
    end

    context "question: weekly_pay_before_tax?" do
      setup do
        testing_node :weekly_pay_before_tax?
        add_responses date_of_redundancy?: 3.years.ago.strftime("%Y-%m-%d"),
                      age_of_employee?: "17",
                      years_employed?: "2"
      end

      should "render question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have next node of done" do
          assert_next_node :done, for_response: "100"
        end
      end
    end
  end
end
