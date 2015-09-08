namespace :smartdown_generate_factcheck do

  def smartdown_factcheck_path(flow_name)
    Rails.root.join('..', "smart-answers-factcheck", flow_name)
  end

  PAY_LEAVE_FOR_PARENTS_SNIPPET_NAMES = {
      "birth-nothing" => "Nothing",
      "adopt-nothing" => "Nothing",
      "single-birth-nothing" => "Nothing",
      "single-adopt-nothing" => "Nothing",
      "adopt-pay-pre-5-april" => "Principal adopter pay (pre 05/04)",
      "mat-allowance-14-weeks" => "Maternity allowance 14 weeks",
      "adopt-leave" => "Principal adopter leave",
      "adopt-pay" => "Principal adopter pay",
      "mat-allowance" => "Maternity allowance",
      "mat-pay" => "Maternity pay",
      "mat-leave" => "Maternity leave",
      "mat-shared-leave" => "Mother shared parental leave",
      "mat-shared-pay" => "Mother shared parental pay",
      "adopt-additional-pat-pay" => "Adopter additional paternity pay",
      "adopt-additional-pat-leave" => "Adopter additional paternity leave",
      "adopt-pat-leave" => "Adopter paternity leave",
      "adopt-pat-pay" => "Adopter paternity pay",
      "adopt-pat-shared-leave" => "Adopter shared parental leave",
      "adopt-pat-shared-pay" => "Adopter shared parental pay",
      "adopt-shared-leave" => "Principal adopter shared parental leave",
      "adopt-shared-pay" => "Principal adopter shared parental pay",
      "pat-leave" => "Paternity leave",
      "pat-pay" => "Paternity pay",
      "additional-pat-pay" => "Additional paternity pay",
      "additional-pat-leave" => "Additional paternity leave",
      "pat-shared-leave" => "Partner shared parental leave",
      "pat-shared-pay" => "Partner shared parental pay",
      "both-shared-leave" => "Mother shared parental leave<br>- Partner shared parental leave",
      "both-shared-pay" => "Mother shared parental pay<br>- Partner shared parental pay",
      "adopt-both-shared-leave" => "Principal adopter shared parental leave<br>- Adopter shared parental leave",
      "adopt-both-shared-pay" => "Principal adopter shared parental pay<br>- Adopter shared parental pay",
  }

  def pay_leave_for_parents_combinations(date)
    {
        circumstance: ["adoption", "birth"],
        two_carers: ["yes", "no"],
        due_date: [date],
        match_date: [date],
        placement_date: ["2014-4-5"],
        employment_status_1: ["employee", "worker", "self-employed", "unemployed"],
        employment_status_2: ["employee", "worker", "self-employed", "unemployed"],
        job_before_x_1: ["yes", "no"],
        job_after_y_1: ["yes", "no"],
        salary_1: ["400-week"],
        lel_1: ["yes", "no"],
        work_employment_1: ["yes", "no"],
        earnings_employment_1: ["yes", "no"],
        salary_1_66_weeks: ["400-week"],
        job_before_x_2: ["yes", "no"],
        job_after_y_2: ["yes", "no"],
        salary_2: ["400-week"],
        lel_2: ["yes", "no"],
        work_employment_2: ["yes", "no"],
        earnings_employment_2: ["yes", "no"],
    }
  end

  desc "Generate factcheck files for pay and leave for parents"
  task pay_leave_for_parents: :environment do
    dates = ["2015-4-5", "2014-4-5"]
    dates.each do |date|
      generator = SmartdownAdapter::PayLeaveParentsFactcheckGenerator.new(
        "pay-leave-for-parents",
        date,
        pay_leave_for_parents_combinations(date),
        PAY_LEAVE_FOR_PARENTS_SNIPPET_NAMES
      )
      generator.perform_and_write_to_file
    end
  end

  desc "Generate diff of factcheck files for pay and leave for parents"
  task diff_pay_leave_for_parents: :environment do
    dates = ["2015-4-5", "2014-4-5"]
    dates.each do |date|
      generator = SmartdownAdapter::PayLeaveParentsFactcheckGenerator.new(
          "pay-leave-for-parents",
          date,
          pay_leave_for_parents_combinations(date),
          PAY_LEAVE_FOR_PARENTS_SNIPPET_NAMES
      )
      new_factcheck_content = generator.perform
      old_factcheck_content = File.read(generator.factcheck_file_path)
      p "Diff for #{date}"
      p Diffy::Diff.new(old_factcheck_content, new_factcheck_content, context: 0)
    end
  end
end
