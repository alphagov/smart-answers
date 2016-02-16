require_relative '../../test_helper'
require 'gds_api/test_helpers/worldwide'

module SmartAnswer::Calculators
  class CountryNameFormatterTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Worldwide

    context '#definitive_article' do
      setup do
        @formatter = CountryNameFormatter.new
        world_locations = %w(antigua-and-barbuda bahamas)
        worldwide_api_has_locations(world_locations)
      end

      should 'return the country name prepended by "the"' do
        assert_equal 'the Bahamas', @formatter.definitive_article('bahamas')
      end

      should 'return the country name prepended by "The"' do
        assert_equal 'The Bahamas', @formatter.definitive_article('bahamas', true)
      end

      should 'return the country name when definite article is not required' do
        assert_equal 'Antigua And Barbuda', @formatter.definitive_article('antigua-and-barbuda')
      end
    end

    context '#requires_definite_article?' do
      setup do
        @formatter = CountryNameFormatter.new
      end

      should 'return true if the country should be prepended by "the"' do
        assert @formatter.requires_definite_article?('bahamas')
      end

      should 'return false if the country should not be prepended by "the"' do
        refute @formatter.requires_definite_article?('antigua-and-barbuda')
      end
    end
  end
end
