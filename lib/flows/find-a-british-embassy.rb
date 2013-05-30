status :draft

data_query = SmartAnswer::Calculators::MarriageAbroadDataQuery.new
i18n_prefix = "flow.find-a-british-embassy"

country_select :choose_embassy_country do
  save_input_as :embassy_country

  calculate :location do
    loc = WorldLocation.find(embassy_country)
    raise InvalidResponse unless loc
    loc
  end
  calculate :country_name do
    if %w(bahamas british-virgin-islands cayman-islands central-african-republic czech-republic democratic-republic-of-congo dominican-republic
          falkland-islands gambia maldives marshall-islands netherlands philippines seychelles solomon-islands united-arab-emirates).include?(location.slug)
      "the #{location.name}"
    else
      location.name
    end
  end

  calculate :organisation do
    location.fco_organisation
  end

  next_node :embassy_outcome
end

outcome :embassy_outcome
