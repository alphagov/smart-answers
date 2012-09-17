satisfies_need "999999"
status :draft

multiple_choice :qualified_motorcycle_instructor? do
  option :no => :over_21?
  option :down_trained_cbt_instructor => :down_trained_cbt_instructor_response
  option :cardington_cbt_instructor => :cardington_cbt_instructor_response
  option :direct_access_instructor => :direct_access_instructor_response
end

multiple_choice :over_21? do
  option :yes => :driving_licence?
  option :no => :too_young
end

multiple_choice :driving_licence? do
  option :yes => :motorcycle_licence?
  option :no => :need_licence
end

multiple_choice :motorcycle_licence? do
  option :yes => :application_instructions
  option :no => :need_longer_licence
end

outcome :down_trained_cbt_instructor_response
outcome :cardington_cbt_instructor_response
outcome :direct_access_instructor_response
outcome :too_young
outcome :need_licence
outcome :application_instructions
outcome :need_longer_licence
