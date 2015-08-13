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
    should "lead to outcome_eu_ft_1415_continuing" do
      add_response 'eu-full-time'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_eu_ft_1415_continuing
    end

    should "lead to outcome_eu_ft_1415_new" do
      add_response 'eu-full-time'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_eu_ft_1415_new
    end

    should "lead to outcome_eu_ft_1516_continuing" do
      add_response 'eu-full-time'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_eu_ft_1516_continuing
    end

    should "lead to outcome_eu_ft_1516_new" do
      add_response 'eu-full-time'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_eu_ft_1516_new
    end

    should "lead to outcome_eu_pt_1415_continuing" do
      add_response 'eu-part-time'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_eu_pt_1415_continuing
    end

    should "lead to outcome_eu_pt_1415_new" do
      add_response 'eu-part-time'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_eu_pt_1415_new
    end

    should "lead to outcome_eu_pt_1516_continuing" do
      add_response 'eu-part-time'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_eu_pt_1516_continuing
    end

    should "lead to outcome_eu_pt_1516_new" do
      add_response 'eu-part-time'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_eu_pt_1516_new
    end
  end

  context "for UK students" do
    should "lead to outcome_uk_ft_1415_continuing" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_uk_ft_1415_continuing
    end

    should "lead to outcome_uk_ft_1415_new" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_uk_ft_1415_new
    end

    should "lead to outcome_uk_ft_1516_continuing" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :outcome_uk_ft_1516_continuing
    end

    should "lead to outcome_uk_ft_1516_new" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :outcome_uk_ft_1516_new
    end

    should "lead to outcome_proof_identity_1415 for full time students" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'proof-identity'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :outcome_proof_identity_1415
    end

    should "lead to outcome_proof_identity_1516 for full time students" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'proof-identity'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :outcome_proof_identity_1516
    end

    should "lead to outcome_parent_partner_1415" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'income-details'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :outcome_parent_partner_1415
    end

    should "lead to outcome_parent_partner_1516" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'income-details'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :outcome_parent_partner_1516
    end

    should "lead to outcome_dsa_1415" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-dsa'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :outcome_dsa_1415
    end

    should "lead to outcome_dsa_1516" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-dsa'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :outcome_dsa_1516
    end

    should "lead to outcome_dsa_expenses for full time students" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'dsa-expenses'
      assert_current_node :outcome_dsa_expenses
    end

    should "lead to outcome_ccg_1415" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-ccg'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :outcome_ccg_1415
    end

    should "lead to outcome_ccg_1516" do
      add_response 'uk-full-time'
      assert_current_node :form_needed_for_1?
      add_response 'apply-ccg'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :outcome_ccg_1516
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

    should "lead to outcome_uk_pt_1415_grant for continuing students" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-before-01092012'
      assert_current_node :outcome_uk_pt_1415_grant
    end

    should "lead to outcome_uk_pt_1415_continuing" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-after-01092012'
      assert_current_node :outcome_uk_pt_1415_continuing
    end

    should "lead to outcome_uk_pt_1415_grant for new students" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-before-01092012'
      assert_current_node :outcome_uk_pt_1415_grant
    end

    should "lead to outcome_uk_pt_1415_new" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-after-01092012'
      assert_current_node :outcome_uk_pt_1415_new
    end

    should "lead to outcome_proof_identity_1415 for part time students" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'proof-identity'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :outcome_proof_identity_1415
    end

    should "lead to outcome_dsa_1415_pt" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-dsa'
      assert_current_node :what_year?
      add_response 'year-1415'
      assert_current_node :outcome_dsa_1415_pt
    end

    should "lead to outcome_uk_ptgc_1516_grant" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-before-01092012'
      # has marker: circumstances_changed
      assert_current_node :outcome_uk_ptgc_1516_grant
    end

    should "lead to outcome_uk_pt_1516_continuing" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :continuing_student?
      add_response 'continuing-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-after-01092012'
      assert_current_node :outcome_uk_pt_1516_continuing
    end

    should "lead to outcome_uk_ptgn_1516_grant" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-before-01092012'
      # has marker: circumstances_changed
      assert_current_node :outcome_uk_ptgn_1516_grant
    end

    should "lead to outcome_uk_pt_1516_new" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-loans-grants'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :continuing_student?
      add_response 'new-student'
      assert_current_node :pt_course_start?
      add_response 'course-start-after-01092012'
      assert_current_node :outcome_uk_pt_1516_new
    end

    should "lead to outcome_proof_identity_1516 for part time students" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'proof-identity'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :outcome_proof_identity_1516
    end

    should "lead to outcome_dsa_1516_pt" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'apply-dsa'
      assert_current_node :what_year?
      add_response 'year-1516'
      assert_current_node :outcome_dsa_1516_pt
    end

    should "lead to outcome_dsa_expenses for part time students" do
      add_response 'uk-part-time'
      assert_current_node :form_needed_for_2?
      add_response 'dsa-expenses'
      assert_current_node :outcome_dsa_expenses
    end
  end
end
