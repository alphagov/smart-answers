module SmartAnswer
  class AmIGettingMinimumWageFlow < Flow
    def define
      content_id "111e006d-2b22-4b1f-989a-56bb61355d68"
      name 'am-i-getting-minimum-wage'
      status :published
      satisfies_need "100145"

      use_erb_templates_for_questions

      use_shared_logic "minimum_wage"
    end
  end
end
