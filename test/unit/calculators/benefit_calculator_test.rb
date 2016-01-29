require_relative '../../test_helper'
require 'gds_api/test_helpers/imminence'

module SmartAnswer::Calculators
  class BenefitCalculatorTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Imminence

    context BenefitCalculator do
      setup do
        # stub post codes
        imminence_has_areas_for_postcode("WC2B%206SE", [{ slug: 'camden-borough-council', country_name: 'England' }, {slug: 'london', country_name: 'England'}])
        imminence_has_areas_for_postcode("B1%201PW",   [{ slug: "birmingham-city-council", country_name: 'England' }])

        @calculator = BenefitCalculator.new
      end

      context '#group_name_for_postcode' do
        should 'return default without a postcode' do
          @calculator.postcode = nil

          assert_equal @calculator.group_name_for_postcode, :default
        end

        should 'return a group name a included postcode' do
          @calculator.postcode = 'WC2B 6SE'

          assert_equal @calculator.group_name_for_postcode, :london
        end

        should 'return default for an invalid postcode' do
          stub_request(:get, %r{\A#{Plek.new.find('imminence')}/areas/E393\.json}).
            to_return(body: { _response_info: { status: 404 }, total: 0, results: [] }.to_json)

          @calculator.postcode = 'E393'

          assert_equal @calculator.group_name_for_postcode, :default
        end
      end

      context '#benefit_cap' do
        should 'default to value for couples' do
          assert_equal @calculator.benefit_cap, @calculator.benefit_cap_rate(:couple)
        end

        should 'return the value for singles' do
          @calculator.single_couple_lone_parent = 'single'

          assert_equal @calculator.benefit_cap, @calculator.benefit_cap_rate(:single)
        end

        should 'return the value for parents' do
          @calculator.single_couple_lone_parent = 'parent'

          assert_equal @calculator.benefit_cap, @calculator.benefit_cap_rate(:parent)
        end

        should 'return a london value for valid postcode' do
          @calculator.postcode = 'WC2B 6SE'

          assert_equal @calculator.benefit_cap, @calculator.benefit_cap_rate(:couple)
        end
      end

      context '#amount' do
        should 'default to 0' do
          assert_equal @calculator.amount(:anything), 0
        end

        should 'return the claimed amount' do
          @calculator.claim(:maternity, 200)

          assert_equal @calculator.amount(:maternity), 200
        end
      end

      context '#total_benefits' do
        should 'default to 0' do
          assert_equal @calculator.total_benefits, 0
        end

        should 'sum claimed benefits' do
          @calculator.claim(:maternity, 200)
          @calculator.claim(:paternity, 100)

          assert_equal @calculator.total_benefits, 300
        end
      end

      context '#total_over_cap' do
        setup do
          @couple_rate = @calculator.benefit_cap_rate(:couple)
          @single_rate = @calculator.benefit_cap_rate(:single)
        end

        should 'return total_benefits minus benefit_cap' do
          assert_equal @calculator.total_benefits, 0
          assert_equal @calculator.benefit_cap, @couple_rate
          assert_equal @calculator.total_over_cap, 0 - @couple_rate

          @calculator.claim(:maternity, 200)
          @calculator.claim(:paternity, 100)

          assert_equal @calculator.total_benefits, 300
          assert_equal @calculator.benefit_cap, @couple_rate
          assert_equal @calculator.total_over_cap, 300 - @couple_rate

          @calculator.single_couple_lone_parent = 'single'

          assert_equal @calculator.total_benefits, 300
          assert_equal @calculator.benefit_cap, @single_rate
          assert_equal @calculator.total_over_cap, 300 - @single_rate
        end
      end
    end
  end
end
