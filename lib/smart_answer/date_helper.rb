module DateHelper
  def next_saturday(date)
    (1..7).each do |inc|
      return date + inc if (date + inc).saturday?
    end
  end
end
