FinanceWeighting = Struct.new(:finance_type, :assets, :property, :shares, :revenue, :funding_min, :funding_max, :employees) do
  def score(answer, criterion)
    result = 0
    weighting_score = send(criterion)
    unless weighting_score.nil?
      result = weighting_score.score(answer).round
    end
    result
  end
end

BooleanWeightingScore = Struct.new(:min, :max, :weight) do
  def score(answer)
    range = answer ? max : min
    range * weight
  end
end

ThresholdWeightingScore = Struct.new(:min, :max, :threshold, :weight) do
  def score(answer)
    range = (answer >= threshold) ? max : min
    range * weight
  end
end

BandedWeightingScore = Struct.new(:bands, :weight) do
  def score(answer)
    range = bands.find { |b| b[:min] <= answer && (!b.has_key?(:max) || b[:max] >= answer) }[:score]
    range * weight
  end
end
