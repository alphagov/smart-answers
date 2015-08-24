require 'date'

class Date
  def finite?
    true
  end

  def infinite?
    !finite?
  end
end

class Date::Infinity
  def to_date
    self
  end
end
