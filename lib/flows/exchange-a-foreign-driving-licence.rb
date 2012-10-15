satisfies_need 1958
status :published

multiple_choice :are_you_resident_in_gb? do
  option :yes => :what_vehicle_licence_do_you_have?
  option :no => :a1
end

multiple_choice :what_vehicle_licence_do_you_have? do
  save_input_as :vehicle_licence

  option :car_motorcycle => :which_country_issued_car_licence?
  option :lorry_bus_minibus => :which_country_issued_bus_licence?
end

multiple_choice :which_country_issued_car_licence? do
  option :eea_ec
  option :ni
  option :jg
  option :des
  option :other

  next_node do |response|
    if vehicle_licence == 'car_motorcycle'
      if response == 'eea_ec'
        :a7
      elsif response == 'ni'
        :a8
      elsif response == 'jg'
        :a9
      elsif response == 'des'
        :which_designated_country_are_you_from?
      elsif response == 'other'
        :a11
      end
    end
  end
end

multiple_choice :which_country_issued_bus_licence? do
  option :eea_ec
  option :ni
  option :jg
  option :gib
  option :other

  next_node do |response|
    if vehicle_licence == 'lorry_bus_minibus'
      if response == 'eea_ec'
        :how_old
      elsif response == 'ni'
        :a3
      elsif response == 'jg'
        :a4
      elsif response == 'gib'
        :a5
      elsif response == 'other'
        :a6
      end
    end
  end
end

multiple_choice :which_designated_country_are_you_from? do
  option :aus => :a10
  option :bar => :a10
  option :bvi => :a10
  option :can => :a10a
  option :falk => :a10
  option :far => :a10b
  option :gib => :a10
  option :hk => :a10
  option :jap => :a10c
  option :mon => :a10
  option :nz => :a10
  option :rok => :a10d
  option :sing => :a10
  option :sa => :a10e
  option :sw => :a10
  option :zim => :a10
end

multiple_choice :how_old do
  option :under_45 => :a2a
  option :between_45_and_65 => :a2b
  option :older_than_66 => :a2c
end

outcome :a1
outcome :a2a
outcome :a2b
outcome :a2c
outcome :a3
outcome :a4
outcome :a5
outcome :a6
outcome :a7
outcome :a8
outcome :a9
outcome :a10
outcome :a10a
outcome :a10b
outcome :a10c
outcome :a10d
outcome :a10e
outcome :a11
