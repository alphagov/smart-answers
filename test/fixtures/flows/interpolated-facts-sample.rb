status :draft

multiple_choice :are_you_ready? do
  option :yes => :ready
  option :no => :not_ready
end

outcome :ready
outcome :not_ready
