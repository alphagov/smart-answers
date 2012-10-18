module SmartAnswer::Calculators
	class MaternityBenefitsCalculator < BirthCalculator

		def test_period
			period_start = qualifying_week.first - 51.weeks
			period_end = expected_week.first - 1.day
			period_start..period_end
		end

	end
end