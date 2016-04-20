require_relative "../../test_helper"

module SmartAnswer::Calculators
  class TranslatorLinksTest < ActiveSupport::TestCase
    context TranslatorLinks do
      setup do
        YAML.stubs(:load_file).returns(
          'spain' => '/government/publications/spain-list-of-lawyers',
          'switzerland' => '/government/publications/switzerland-list-of-lawyers',
          'andorra' => '/government/publications/spain-list-of-lawyers',
          'san-marino' => '/government/publications/italy-list-of-lawyers'
        )
        @data = TranslatorLinks.new
      end

      should "allow access to Hash" do
        assert @data.links.is_a?(Hash)
      end

      context "correct translator links" do
        should "give correct link for Spain" do
          assert_equal "/government/publications/spain-list-of-lawyers", @data.links['spain']
        end

        should "give correct link for Switzerland" do
          assert_equal "/government/publications/switzerland-list-of-lawyers", @data.links['switzerland']
        end

        should "give Spain link for Andorra" do
          assert_equal "/government/publications/spain-list-of-lawyers", @data.links['andorra']
        end

        should "give Italy link for San-Marino" do
          assert_equal "/government/publications/italy-list-of-lawyers", @data.links['san-marino']
        end
      end

      context "refutation should abound" do
        should "not return anything for specified countries" do
          refute @data.links['pitcairn']
        end
      end
    end
  end
end
