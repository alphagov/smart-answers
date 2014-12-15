namespace :pay_leave_for_parents do

  desc "Regenerate outcomes files from flow and available snippets"
  task :generate_outcomes => :environment do
    flow = SmartdownAdapter::Registry.instance.find("pay-leave-for-parents")

    def nested_outcomes(rules)
      rules.map { |rule|
        if rule.respond_to? :outcome
          rule.outcome
        else
          nested_outcomes(rule.children)
        end
      }
    end

    cover_node = flow.name.to_s

    start_node = flow.coversheet.elements.find { |e|
      e.is_a?(Smartdown::Model::Element::StartButton)
    }.start_node.to_s

    destination_nodes = flow.nodes.map(&:elements).flatten.select { |e|
      e.is_a?(Smartdown::Model::NextNodeRules)
    }.map(&:rules).map {
        |rules| nested_outcomes(rules)
    }.flatten.map(&:to_s).uniq

    all_nodes = ([cover_node, start_node] + flow.nodes.map(&:name))

    missing_nodes = destination_nodes - all_nodes

    missing_nodes.each do |node_name|
      node_filepath = File.join(smartdown_flow_path(flow.name), "outcomes", "#{node_name}.txt")
      _, *node_aspects = node_name.split('_')

      node_content = node_aspects.map { |aspect|
        "{{snippet: #{aspect}}}"}.join("\n\n")+"\n\n{{snippet: extra-help}}\n"

      File.write(node_filepath, node_content)
    end
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
      :lel_1 => ["yes", "no"],
      :work_employment_1 => ["yes", "no"],
      :earnings_employment_1 => ["yes", "no"],
      :salary_1_66_weeks => ["400-week"],
      :job_before_x_2 => ["yes", "no"],
      :job_after_y_2 => ["yes", "no"],
      :salary_2 => ["400-week"],
      :lel_2 => ["yes", "no"],
      :work_employment_2 => ["yes", "no"],
      :earnings_employment_2 => ["yes", "no"],
    }
  end

  desc "Generate factcheck files for pay and leave for parents"
  task :generate_factcheck => :environment do
    dates = ["2015-4-5", "2014-4-5"]
    dates.each do |date|
      generator = SmartdownAdapter::Utils::PayLeaveParentsFactcheckGenerator.new(
        "pay-leave-for-parents",
        date,
        pay_leave_for_parents_combinations(date),
        PAY_LEAVE_FOR_PARENTS_SNIPPET_NAMES
      )
      generator.perform_and_write_to_file
    end
  end
end
