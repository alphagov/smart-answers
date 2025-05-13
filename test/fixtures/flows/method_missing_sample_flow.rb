class MethodMissingSampleFlow < SmartAnswer::Flow
  def define
    name "method-missing-sample"
    money_question :how_much_are_you_owed? do
      next_node do
        outcome :done
      end
    end
    outcome :done
  end
end
