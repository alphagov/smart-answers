satisfies_need 9
status :published

multiple_choice :are_you? do
  option :resident_of_gb => :what_vehicle_licence_do_you_have?
  option :visitor_to_gb => :where_was_licence_issued?
  option :student_in_gb => :where_are_you_from?
end

multiple_choice :what_vehicle_licence_do_you_have? do
  save_input_as :vehicle_licence

  option :car_motorcycle => :which_country_issued_car_licence?
  option :lorry_bus_minibus => :which_country_issued_bus_licence?
end

multiple_choice :which_country_issued_car_licence? do
  option :ni
  option :eea_ec
  option :gib_j_g_iom_desig
  option :other

  next_node do |response|
    if vehicle_licence == 'car_motorcycle'
      if response == 'ni'
        :a1
      elsif response == 'eea_ec'
        :a2
      elsif response == 'gib_j_g_iom_desig'
        :a3
      elsif response == 'other'
        :a4
      end
    end
  end
end

multiple_choice :which_country_issued_bus_licence? do
  option :ni
  option :eea_ec
  option :gib_j_g_iom
  option :designated
  option :other

  next_node do |response|
    if vehicle_licence == 'lorry_bus_minibus'
      if response == 'ni'
        :a5
      elsif response == 'eea_ec'
        :a6
      elsif response == 'gib_j_g_iom'
        :a7
      elsif response == 'designated'
        :a8
      elsif response == 'other'
        :a9
      end
    end
  end
end

multiple_choice :where_was_licence_issued? do
  option :ni_eea_ec => :a10
  option :j_g_iom => :a11
  option :other => :a12
end

multiple_choice :where_are_you_from? do
  option :eea_ec => :a13
  option :non_eea_ec => :a14
end

outcome :a1
outcome :a2
outcome :a3
outcome :a4
outcome :a5
outcome :a6
outcome :a7
outcome :a8
outcome :a9
outcome :a10
outcome :a11
outcome :a12
outcome :a13
outcome :a14
