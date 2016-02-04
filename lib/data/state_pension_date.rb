StatePensionDate = Struct.new(:gender, :start_date, :end_date, :pension_date) do
  def match?(dob, sex)
    same_gender?(sex) && born_in_range?(dob)
  end

  def same_gender?(sex)
    gender == sex || :both == gender
  end

  def born_in_range?(dob)
    dob >= start_date && dob <= end_date
  end
end
