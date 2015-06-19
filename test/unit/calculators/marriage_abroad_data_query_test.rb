require_relative "../../test_helper"

module SmartAnswer::Calculators
  class MarriageAbroadDataQueryTest < ActiveSupport::TestCase
    context MarriageAbroadDataQuery do
      setup do
        @query = MarriageAbroadDataQuery.new
      end

      context "#appointment_link_key_for" do
        should "return nil if there is no key" do
          link = @query.appointment_link_key_for('narnia', 'opposite_sex')
          assert_nil link
        end

        should "return a key relative to 'flow.marriage-abroad.phrases.'" do
          I18n.stubs(:exists?).with("flow.marriage-abroad.phrases.appointment_links.opposite_sex.turkey").returns(true)
          link = @query.appointment_link_key_for('turkey', 'opposite_sex')
          assert_equal 'appointment_links.opposite_sex.turkey', link
        end
      end
    end
  end
end
