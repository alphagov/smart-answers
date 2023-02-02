require "test_helper"

module SmartAnswer::Calculators
  class InheritsSomeoneDiesWithoutWillCalculatorTest < ActiveSupport::TestCase
    def calculator
      @calculator ||= InheritsSomeoneDiesWithoutWillCalculator.new
    end

    def methods
      %i[
        partner
        estate_over_250000
        children
        parents
        siblings
        siblings_including_mixed_parents
        grandparents
        aunts_or_uncles
        half_siblings
        half_aunts_or_uncles
        great_aunts_or_uncles
        more_than_one_child
      ]
    end

    context "boolean method" do
      should "should return true with 'yes' response" do
        methods.each do |method|
          calculator.send "#{method}=", "yes"
          assert calculator.send("#{method}?"), "calculator.#{method}? should return true"
        end
      end

      should "should return false with 'no' response" do
        methods.each do |method|
          calculator.send "#{method}=", "no"
          assert_not calculator.send("#{method}?"), "calculator.#{method}? should return false"
        end
      end
    end
  end
end
