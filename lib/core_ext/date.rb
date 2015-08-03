require 'date'

class Date
  def infinite?
    false
  end
end

class Date::Infinity
  def to_date
    self
  end
end
