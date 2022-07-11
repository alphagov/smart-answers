class YearSampleFlow < SmartAnswer::Flow
  def define
    name "year-sample"

    year_question :what_year? do
      next_node do
        outcome :done
      end
    end
    outcome :done
  end
end
