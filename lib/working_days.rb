require 'gds_api/base'
require 'gds_api/json_client'

class WorkingDays
  WEEKDAYS = 1..5
  BANK_HOLIDAYS_URL = 'https://www.gov.uk/bank-holidays.json'

  def initialize(days)
    @days = days
  end

  def after(date)
    days = @days
    while days > 0 || !workday?(date)
      date += 1.day
      days -= 1 if workday?(date)
    end
    date
  end

  def before(date)
    days = @days
    while days > 0 || !workday?(date)
      date -= 1.day
      days -= 1 if workday?(date)
    end
    date
  end

  def self.workday?(date)
    WEEKDAYS.include?(date.wday) && !bank_holidays.include?(date)
  end

private

  def workday?(date)
    self.class.workday?(date)
  end

  def self.bank_holidays
    @bank_holidays ||= load_bank_holidays
  end

  def self.load_bank_holidays
    response = GdsApi::JsonClient.new(disable_cache: true).get_json!(BANK_HOLIDAYS_URL)

    response['england-and-wales']['events'].map do |event|
      Date.parse(event["date"])
    end
  end
end

Fixnum.class_eval do
  def working_days
    WorkingDays.new(self)
  end
  alias :working_day :working_days
end

Date.class_eval do
  def workday?
    WorkingDays.workday?(self)
  end
end
