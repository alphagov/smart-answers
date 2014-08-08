module Smartdown
  class Registry

    def self.check(name)
      smartdown_questions = ["animal-example"]
      smartdown_questions.include? name
    end

  end
end
