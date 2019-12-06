module SmartAnswer
  class DateOfBirth
    def initialize(date_of_birth)
      @date_of_birth = date_of_birth
    end

    def birthday(year: Time.zone.today.year)
      month = @date_of_birth.month
      day = @date_of_birth.day
      if !Date.new(year).leap? && month == 2 && day == 29
        month = 3
        day = 1
      end
      Date.new(year, month, day)
    end

    def age(on: Time.zone.today)
      years = on.year - @date_of_birth.year
      if birthday(year: on.year) > on
        years -= 1
      end
      years
    end
  end
end
