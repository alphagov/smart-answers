module DateTestHelper
  def next_saturday(date)
    (1..7).each do |inc|
      return date + inc if (date + inc).send(:saturday?)
    end
  end
end
