namespace :smartdown_generate_scenarios do

  def generate(name, combinations)
    generator = SmartdownAdapter::ScenarioGenerator.new("employee-parental-leave", EMPLOYEE_PARENTAL_LEAVE_COMBINATIONS)
    generator.perform
  end

  desc "Generate Factcheck scenarios for employee parental leave"
  task :employee_parental_leave => :environment do
    EMPLOYEE_PARENTAL_LEAVE_COMBINATIONS = {
      :circumstance => ["adoption", "birth"],
      :single_parent => ["yes", "no"],
      :due_date => ["2015-4-5", "2014-4-5"],
      :match_date => ["2015-4-5", "2014-4-5"],
      :placement_date => ["2014-4-5"],
      :employment_status_1 => ["employee", "worker", "self-employed", "unemployed"], #agency are ignored
      :employment_status_2 => ["employee", "worker", "unemployed"], #agency, self-employed are ignored
      :job_before_x_1 => ["yes", "no"],
      :job_after_y_1 => ["yes", "no"],
      :salary_1 => ["400-week"],
      :ler_1 => ["yes", "no"],
      :earnings_employment_1 => ["yes", "no"],
      :job_before_x_2 => ["yes", "no"],
      :job_after_y_2 => ["yes", "no"],
      :salary_2 => ["400-week"],
      :ler_2 => ["yes", "no"],
      :earnings_employment_2 => ["yes", "no"],
      :date_leave_1 => ["2015-4-5"],
      :date_leave_2 => ["2015-4-5"],
    }
    generate("employee-parental-leave", EMPLOYEE_PARENTAL_LEAVE_COMBINATIONS)
  end
end
