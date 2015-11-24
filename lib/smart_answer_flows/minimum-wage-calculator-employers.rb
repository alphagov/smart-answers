module SmartAnswer
  class MinimumWageCalculatorEmployersFlow < Flow
    def define
      content_id "cc25f6ca-0553-4400-9dba-a43294fee84b"
      name 'minimum-wage-calculator-employers'
      status :published
      satisfies_need "100145"

      use_erb_templates_for_questions

      use_shared_logic "minimum_wage"
    end
  end
end
