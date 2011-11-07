multiple_choice :country_is_listed_in_your_passport? do
  option eu_and_swiss: :eligiable_to_work_eu
  option bulgaria_or_romania: :maybe_eligiable_if_self_employed
  option :non_eu => :are_you_a_skilled_worker_with_a_job_offer_in_the_UK?
end

multiple_choice :are_you_a_skilled_worker_with_a_job_offer_in_the_UK? do
  option yes: :maybe_eligiable_to_work
  option no: :nature_of_work?
end

multiple_choice :nature_of_work? do
  option entrepreneur: :maybe_eligiable_to_work
  option investor:  :maybe_eligiable_to_work
  option skilled_worker: :eligiable_to_work_tier2
  option student: :maybe_eligiable_to_work
  option temporary_worker: :maybe_eligiable_to_work
  option on_the_youth_mobility_scheme: :maybe_eligiable_to_work
  option unskilled_work: :not_eligiable_to_work
end

outcome :eligiable_to_work_eu
outcome :eligiable_to_work_tier2
outcome :not_eligiable_to_work
outcome :maybe_eligiable_to_work
outcome :maybe_eligiable_if_self_employed
