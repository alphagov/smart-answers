require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MaternityBenefitsCalculatorTest < ActiveSupport::TestCase
  	context MaternityBenefitsCalculator do 
  		context "basic tests" do
	  		setup do
		    	@due_date = Date.parse("2013-01-02")
		      @calculator = MaternityBenefitsCalculator.new(@due_date)
		    end
	  		should "return basic calcs" do
	  			assert_equal @due_date, @calculator.due_date
	  			assert_equal Date.parse("2012-12-30")..Date.parse("2013-01-05"), @calculator.expected_week
	  		end
	  	end

	  	context "editor tests" do
				# Birth 22/12/12
				# QW 02/09/12 - 08/09/12
				# Employ start 17/03/12 
	  		context "birth 2012 Dec 22" do
		  		setup do
			    	@due_date = Date.parse("2012 Dec 22")
			      @calculator = MaternityBenefitsCalculator.new(@due_date)
			    end
			    should "qualifying week" do
			    	assert_equal Date.parse("02 Sep 2012")..Date.parse("08 Sep 2012"), @calculator.qualifying_week
			    end
			    should "employment start" do
			    	assert_equal Date.parse("17 Mar 2012"), @calculator.employment_start
			    end
			    should "test period" do
			    	assert_equal Date.parse("2011 Sep 11")..Date.parse("2012 Dec 15"), @calculator.test_period
			    end
			  end
	  	end
  	end

    context "uprating calculations" do
      context "before 7th April 2013" do
        setup do
          @calculator = MaternityBenefitsCalculator.new(Date.parse("5th April 2013"))
        end

        should "have an smp_rate of 135.45" do
          assert_equal 135.45, @calculator.smp_rate
        end

        should "have an ma_rate of 135.45" do
          assert_equal 135.45, @calculator.ma_rate
        end

        should "have an smp_LEL of 135.45" do
          assert_equal 107, @calculator.smp_LEL
        end
      end

      context "after 7th April 2013" do
        setup do
          @calculator = MaternityBenefitsCalculator.new(Date.parse("8th April 2013"))
        end

        should "have an smp_rate of 136.78" do
          assert_equal 136.78, @calculator.smp_rate
        end

        should "have an ma_rate of 135.45" do
          assert_equal 136.78, @calculator.ma_rate
        end
      end

      context "after 14th July 2013" do
        setup do
          @calculator = MaternityBenefitsCalculator.new(Date.parse("14th July 2013"))
        end

        should "have an smp_LEL of 135.45" do
          assert_equal 109, @calculator.smp_LEL
        end
      end
    end

    context "eleven_weeks" do
      should "work out earliest date maternity allowance payments can start" do
        calculator = MaternityBenefitsCalculator.new(Date.parse("1st April 2013"))
        assert_equal Date.parse("14 Jan 2013"), calculator.eleven_weeks
      end
    end
  end
end
