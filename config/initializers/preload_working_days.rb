require 'working_days'

# Don't preload the bank_holidays in test, so that we can stub out the calls in test setup methods.
unless Rails.env.test?
  # This loads the bank holiday dates from https://www.gov.uk/bank-holidays.json
  WorkingDays.bank_holidays
end
