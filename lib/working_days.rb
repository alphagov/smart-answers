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

  class << self
    def bank_holidays
      @bank_holidays ||= load_bank_holidays
    end

  private

    def load_bank_holidays
      return get_bank_holidays unless Rails.env.development? || Rails.env.test?
      load_from_cache || write_to_cache(get_bank_holidays)
    end

    def load_from_cache
      File.exists?(cache_path) && Marshal.load(Base64.decode64(File.read(cache_path)))
    end

    def write_to_cache(data)
      File.open(cache_path, 'w') do |f|
        f.puts Base64.encode64(Marshal.dump(data))
      end
      data
    end

    def cache_path
      Rails.root.join("tmp/bank-holidays-cache-#{Date.today.strftime('%Y-%m-%d')}.dump")
    end

    def get_bank_holidays
      response = GdsApi::JsonClient.new(disable_cache: true).get_json(BANK_HOLIDAYS_URL)

      response['england-and-wales']['events'].map do |event|
        Date.parse(event["date"])
      end
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
