class DateSampleFlow < SmartAnswer::Flow
  def define
    name "date-sample"

    date_question :when? do
      next_node do
        outcome :done
      end
    end
    outcome :done
  end
end
