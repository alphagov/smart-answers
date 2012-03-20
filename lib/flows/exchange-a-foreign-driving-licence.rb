satisfies_need 9999
section_slug "driving"
status :draft

multiple_choice :are_you_resident_in_gb? do
  option :yes => :what_vehicle_licence_do_you_have?
  option :no => :a1
end

multiple_choice :what_vehicle_licence_do_you_have? do
  save_input_as :vehicle_licence

  option :lorry_bus_minibus => :which_country_issued_licence?
  option :car_motorcycle => :which_country_issued_licence?
end

multiple_choice :which_country_issued_licence? do
  option :eea_ec
  option :ni
  option :jg
  option :gib
  option :other

  next_node do |response|
    if vehicle_licence == 'lorry_bus_minibus'
      if response == 'eea_ec'
        :a2
      elsif response == 'ni'
        :a3
      elsif response == 'jg'
        :a4
      elsif response == 'gib'
        :a5
      elsif response == 'other'
        :a6
      end
    else
      if response == 'eea_ec'
        :a7
      elsif response == 'ni'
        :a8
      elsif response == 'jg'
        :a9
      elsif response == 'gib'
        :a10
      elsif response == 'other'
        :a11
      end
    end
  end
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
