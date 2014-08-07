module Smartdown
  class Registry

    def self.check(name)
      smartdown_questions = ["animal-example", "student-finance-forms-sd"]
      smartdown_questions.include? name
    end

  end
end
