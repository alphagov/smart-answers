satisfies_need "392"
status :draft

multiple_choice :which_case? do
  option :going_abroad => :have_you_paid_ni_in_the_uk?
  option :currently_abroad => :have_you_paid_ni_in_the_uk?
  option :back_in_the_uk => :which_country_did_you_work_in?
end

use_shared_logic :benefits_abroad
use_shared_logic :benefits_abroad_back_in_uk
