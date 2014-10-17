namespace :smartdown_generate_scenarios do

  def generate(name, combinations)
    generator = SmartdownAdapter::ScenarioGenerator.new(name, combinations)
    generator.perform
  end

  def smartdown_factcheck_path(flow_name)
    Rails.root.join('..', "smart-answers-factcheck", flow_name)
  end

  desc "Generate scenarios for employee parental leave"
  task :employee_parental_leave => :environment do
    combinations = {
      :circumstance => ["adoption", "birth"],
      :two_carers => ["yes", "no"],
      :due_date => ["2015-4-5", "2014-4-5"],
      :match_date => ["2015-4-5", "2014-4-5"],
      :placement_date => ["2014-4-5"],
      :employment_status_1 => ["employee", "worker", "self-employed", "unemployed"],
      :employment_status_2 => ["employee", "worker", "self-employed", "unemployed"],
      :job_before_x_1 => ["yes", "no"],
      :job_after_y_1 => ["yes", "no"],
      :salary_1 => ["400-week"],
      :ler_1 => ["yes", "no"],
      :earnings_employment_1 => ["yes", "no"],
      :salary_1_66_weeks => ["400-week"],
      :job_before_x_2 => ["yes", "no"],
      :job_after_y_2 => ["yes", "no"],
      :salary_2 => ["400-week"],
      :ler_2 => ["yes", "no"],
      :earnings_employment_2 => ["yes", "no"],
    }
    generate("employee-parental-leave", combinations)
  end

  desc "Generate factcheck files for employee parental leave"
  task :employee_parental_leave_factcheck => :environment do
    dates = ["2015-4-5", "2014-4-5"]
    dates.each do |date|
      combinations = {
        :circumstance => ["adoption", "birth"],
        :two_carers => ["yes", "no"],
        :due_date => [date],
        :match_date => [date],
        :placement_date => ["2014-4-5"],
        :employment_status_1 => ["employee", "worker", "self-employed", "unemployed"],
        :employment_status_2 => ["employee", "worker", "self-employed", "unemployed"],
        :job_before_x_1 => ["yes", "no"],
        :job_after_y_1 => ["yes", "no"],
        :salary_1 => ["400-week"],
        :ler_1 => ["yes", "no"],
        :earnings_employment_1 => ["yes", "no"],
        :salary_1_66_weeks => ["400-week"],
        :job_before_x_2 => ["yes", "no"],
        :job_after_y_2 => ["yes", "no"],
        :salary_2 => ["400-week"],
        :ler_2 => ["yes", "no"],
        :earnings_employment_2 => ["yes", "no"],
      }
      human_readable_snippet_names = {
        "birth-nothing" => "Nothing",
        "adopt-nothing" => "Nothing",
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
      }
      generator = SmartdownAdapter::SplFactcheckGenerator.new("employee-parental-leave", date, combinations, human_readable_snippet_names)
      generator.perform
    end
  end
end
