class SalarySampleFlow < SmartAnswer::Flow
  def define
    name "salary-sample"
    salary_question(:how_much?) do
      next_node do
        question :salary_question_with_error_message?
      end
    end
    salary_question(:salary_question_with_error_message?) do
      next_node do
        outcome :done
      end
    end
    outcome :done
  end
end
