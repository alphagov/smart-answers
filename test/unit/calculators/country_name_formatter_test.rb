require_relative '../../test_helper'
require 'gds_api/test_helpers/worldwide'

module SmartAnswer::Calculators
  class CountryNameFormatterTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Worldwide

    context '#definitive_article' do
      setup do
        @formatter = CountryNameFormatter.new
      end

      should 'return the country name prepended by "the"' do
        worldwide_api_has_location('bahamas')
        assert_equal 'the Bahamas', @formatter.definitive_article('bahamas')
      end

      should 'return the country name prepended by "The"' do
        worldwide_api_has_location('bahamas')
        assert_equal 'The Bahamas', @formatter.definitive_article('bahamas', true)
      end

      should 'return the country name when definite article is not required' do
        worldwide_api_has_location('antigua-and-barbuda')
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

    context 'has_friendly_name?' do
      setup do
        @formatter = CountryNameFormatter.new
      end

      should 'return true if the country slug has a friendly name' do
        assert @formatter.has_friendly_name?('democratic-republic-of-congo')
      end

      should 'return false if the country slug does not have a friendly name' do
        refute @formatter.has_friendly_name?('antigua-and-barbuda')
      end
    end

    context '#friendly_name' do
      setup do
        @formatter = CountryNameFormatter.new
      end

      should 'return the friendly name for the country' do
        assert_equal 'Democratic Republic of Congo', @formatter.friendly_name('democratic-republic-of-congo')
      end
    end
  end
end
