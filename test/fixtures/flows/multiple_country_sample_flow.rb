class MultipleCountrySampleFlow < SmartAnswer::Flow
  def define
    name "multiple-country-sample"
    multiple_country_select :countries do
      self.select_count = 2
      next_node do
        outcome :done
      end
    end
    outcome :done
  end
end
