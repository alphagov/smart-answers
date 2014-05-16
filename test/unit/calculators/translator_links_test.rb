require_relative "../../test_helper"

module SmartAnswer::Calculators
  class TranslatorLinksTest < ActiveSupport::TestCase
    context TranslatorLinks do
      setup do
        @links = SmartAnswer::Calculators::TranslatorLinks.new
      end
      
      context "correct translator links" do
        should "give correct link for Spain" do
          assert_equal "/government/publications/spain-list-of-lawyers", @links.translator_link('spain')
          refute @links.translator_link('usa')
        end
        
        should "give correct link for Switzerland" do
          assert_equal "/government/publications/switzerland-list-of-lawyers", @links.translator_link('switzerland')
          refute @links.translator_link('afghanistan')
        end
        
        should "give Spain link for Andorra" do
          assert_equal "/government/publications/spain-list-of-lawyers", @links.translator_link('andorra')
          refute @links.translator_link('pitcairn')
        end
        
        should "give Italy link for San-Marino" do
          assert_equal "/government/publications/italy-list-of-lawyers", @links.translator_link('san-marino')
          refute @links.translator_link('seychelles')
        end
      end
      
    end
  end
end