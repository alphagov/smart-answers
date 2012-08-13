satisfies_need "999999"
status :draft
section_slug "driving"

multiple_choice :qualified_motorcycle_instructor? do
  option :no => :over_21?
  option :down_trained_cbt_instructor => :down_trained_cbt_instructor_response
  option :cardington_cbt_instructor => :cardington_cbt_instructor_response
  option :direct_access_instructor => :direct_access_instructor_response
end

multiple_choice :over_21? do
end

outcome :down_trained_cbt_instructor_response
outcome :cardington_cbt_instructor_response
outcome :direct_access_instructor_response