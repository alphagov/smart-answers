satisfies_need "B91"
section_slug "work"
subsection_slug ""
status :draft

multiple_choice :have_uk_passport? do
  option :yes => :is_british_citizen?
  option :no => :where_from?
end

multiple_choice :is_british_citizen? do
  option :yes => :is_eligible1
  option :no => :has_right_of_abode?
end

multiple_choice :has_right_of_abode? do
  option :yes => :is_eligible1
  option :no => :needs_up_to_date_docs
end

multiple_choice :where_from? do
  option :british => :is_eligible2
  option :from_ci_iom_ri => :is_eligible1
  option :from_eu_eea_switzerland => :has_eu_passport_or_id?
  option :from_somewhere_else => :has_other_permit?
end


multiple_choice :has_eu_passport_or_id? do
  option :yes => :is_eligible3
  option :no => :has_named_person?
end

multiple_choice :has_named_person? do
  option :yes => :is_eligible3
  option :no => :maybe1
end

multiple_choice :has_other_permit? do
  option :yes => :is_eligible1
  option :no => :has_nic_and_other_doc?
end

multiple_choice :has_nic_and_other_doc? do
  option :yes => :is_eligible2
  option :no => :has_visa_or_other_doc?
end

multiple_choice :has_visa_or_other_doc? do
  option :yes => :maybe1
  option :no => :maybe2
end


outcome :is_eligible1
outcome :is_eligible2
outcome :is_eligible3
outcome :needs_up_to_date_docs
outcome :maybe1
outcome :maybe2