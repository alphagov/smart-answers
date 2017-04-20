require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/student-finance-forms"

class StudentFinanceFormsTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::StudentFinanceFormsFlow
  end

  should "start off by asking what type of student you are" do
    assert_current_node :type_of_student?
  end

  context "for EU students" do
    should "lead to outcome_eu_ft_1718_continuing" do
      add_response 'eu-full-time'
      assert_current_node :what_year_full_time?
      add_response 'year-1718'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_eu_ft_1718_continuing
    end

    should "lead to outcome_eu_ft_1718_new" do
      add_response 'eu-full-time'
      assert_current_node :what_year_full_time?
      add_response 'year-1718'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_eu_ft_1718_new
    end

    should "lead to outcome_eu_ft_1617_continuing" do
      add_response 'eu-full-time'
      assert_current_node :what_year_full_time?
      add_response 'year-1617'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_eu_ft_1617_continuing
    end

    should "lead to outcome_eu_ft_1617_new" do
      add_response 'eu-full-time'
      assert_current_node :what_year_full_time?
      add_response 'year-1617'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_eu_ft_1617_new
    end

    should "lead to outcome_eu_pt_1617_continuing" do
      add_response 'eu-part-time'
      assert_current_node :what_year_part_time?
      add_response 'year-1617'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_eu_pt_1617_continuing
    end

    should "lead to outcome_eu_pt_1617_new" do
      add_response 'eu-part-time'
      assert_current_node :what_year_part_time?
      add_response 'year-1617'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_eu_pt_1617_new
    end

    should "lead to outcome_eu_pt_1718_continuing" do
      add_response 'eu-part-time'
      assert_current_node :what_year_part_time?
      add_response 'year-1718'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_eu_pt_1718_continuing
    end

    should "lead to outcome_eu_pt_1718_new" do
      add_response 'eu-part-time'
      assert_current_node :what_year_part_time?
      add_response 'year-1718'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_eu_pt_1718_new
    end
  end

  context "for UK students" do
    should "lead to outcome_uk_ft_1718_continuing" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_full_time?
      add_response 'year-1718'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_uk_ft_1718_continuing
    end

    should "lead to outcome_uk_ft_1718_new" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_full_time?
      add_response 'year-1718'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_uk_ft_1718_new
    end

    should "lead to outcome_uk_ft_1617_continuing" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_full_time?
      add_response 'year-1617'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_uk_ft_1617_continuing
    end

    should "lead to outcome_uk_ft_1617_new" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_full_time?
      add_response 'year-1617'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_uk_ft_1617_new
    end

    should "lead to outcome_proof_identity_1718 for full time students" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'proof-identity'
      assert_current_node :what_year_full_time?
      add_response 'year-1718'
      assert_current_node :outcome_proof_identity_1718
    end

    should "lead to outcome_proof_identity_1617 for full time students" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'proof-identity'
      assert_current_node :what_year_full_time?
      add_response 'year-1617'
      assert_current_node :outcome_proof_identity_1617
    end

    should "lead to outcome_parent_partner_1718" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'income-details'
      assert_current_node :what_year_full_time?
      add_response 'year-1718'
      assert_current_node :outcome_parent_partner_1718
    end

    should "lead to outcome_parent_partner_1617" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'income-details'
      assert_current_node :what_year_full_time?
      add_response 'year-1617'
      assert_current_node :outcome_parent_partner_1617
    end

    should "lead to outcome_dsa_1718" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-dsa'
      assert_current_node :what_year_full_time?
      add_response 'year-1718'
      assert_current_node :outcome_dsa_1718
    end

    should "lead to outcome_dsa_1617" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-dsa'
      assert_current_node :what_year_full_time?
      add_response 'year-1617'
      assert_current_node :outcome_dsa_1617
    end

    should "lead to outcome_dsa_expenses for full time students" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'dsa-expenses'
      assert_current_node :outcome_dsa_expenses
    end

    should "lead to outcome_ccg_1718" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-ccg'
      assert_current_node :what_year_full_time?
      add_response 'year-1718'
      assert_current_node :outcome_ccg_1718
    end

    should "lead to outcome_ccg_1617" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-ccg'
      assert_current_node :what_year_full_time?
      add_response 'year-1617'
      assert_current_node :outcome_ccg_1617
    end

    should "lead to outcome_travel" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'travel-grant'
      assert_current_node :outcome_travel
    end

    should "lead to outcome_ccg_expenses" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'ccg-expenses'
      assert_current_node :outcome_ccg_expenses
    end

    should "lead to outcome_uk_pt_1617_grant_continuing for continuing students" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_part_time?
      add_response 'year-1617'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-before-01092012'
      assert_current_node :outcome_uk_pt_1617_grant_continuing
    end

    should "lead to outcome_uk_pt_1617_continuing" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_part_time?
      add_response 'year-1617'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-after-01092012'
      assert_current_node :outcome_uk_pt_1617_continuing
    end

    should "lead to outcome_uk_pt_1617_grant_new for new students" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_part_time?
      add_response 'year-1617'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-before-01092012'
      assert_current_node :outcome_uk_pt_1617_grant_new
    end

    should "lead to outcome_uk_pt_1617_new" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_part_time?
      add_response 'year-1617'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-after-01092012'
      assert_current_node :outcome_uk_pt_1617_new
    end

    should "lead to outcome_proof_identity_1617 for part time students" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'proof-identity'
      assert_current_node :what_year_part_time?
      add_response 'year-1617'
      assert_current_node :outcome_proof_identity_1617
    end

    should "lead to outcome_dsa_1617_pt" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-dsa'
      assert_current_node :what_year_part_time?
      add_response 'year-1617'
      assert_current_node :outcome_dsa_1617_pt
    end

    should "lead to outcome_uk_pt_1718_grant_continuing" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_part_time?
      add_response 'year-1718'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-before-01092012'
      assert_current_node :outcome_uk_pt_1718_grant_continuing
    end

    should "lead to outcome_uk_pt_1718_continuing" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_part_time?
      add_response 'year-1718'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-after-01092012'
      assert_current_node :outcome_uk_pt_1718_continuing
    end

    should "lead to outcome_uk_pt_1718_grant_new" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_part_time?
      add_response 'year-1718'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-before-01092012'
      assert_current_node :outcome_uk_pt_1718_grant_new
    end

    should "lead to outcome_uk_pt_1718_new" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year_part_time?
      add_response 'year-1718'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-after-01092012'
      assert_current_node :outcome_uk_pt_1718_new
    end

    should "lead to outcome_proof_identity_1718 for part time students" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'proof-identity'
      assert_current_node :what_year_part_time?
      add_response 'year-1718'
      assert_current_node :outcome_proof_identity_1718
    end

    should "lead to outcome_dsa_1718_pt" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-dsa'
      assert_current_node :what_year_part_time?
      add_response 'year-1718'
      assert_current_node :outcome_dsa_1718_pt
    end

    should "lead to outcome_dsa_expenses for part time students" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'dsa-expenses'
      assert_current_node :outcome_dsa_expenses
    end
  end
end
