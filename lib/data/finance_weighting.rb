class FinanceWeighting < Struct.new(:finance_type, :assets, :property, :shares, :funding_min, :funding_max, :employees)
  def score(answer, criterion)
    result = 0
    weighting_score = send(criterion)
    unless weighting_score.nil?
      result = weighting_score.score(answer)
    end
    result
  end
end

class BooleanWeightingScore < Struct.new(:min, :max, :weight)
  def score(answer)
    range = answer ? max : min
    range * weight
  end
end

class ThresholdWeightingScore < Struct.new(:min, :max, :threshold, :weight)
  def score(answer)
    range = answer >= threshold ? max : min
    range * weight
  end
end
