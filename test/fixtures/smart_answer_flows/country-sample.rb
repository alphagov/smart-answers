class CountrySampleFlow < SmartAnswer::Flow
  def define
    name "country-sample"
    country_select :country? do
      next_node do
        outcome :done
      end
    end
    outcome :done
  end
end
