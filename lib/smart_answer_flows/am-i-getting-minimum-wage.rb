module SmartAnswer
  class AmIGettingMinimumWageFlow < Flow
    def define
      name 'am-i-getting-minimum-wage'
      status :published
      satisfies_need "100145"

      use_outcome_templates
      use_shared_logic "minimum_wage"
    end
  end
end
