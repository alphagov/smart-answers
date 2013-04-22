module SmartAnswer
  module Question
    class CountrySelect < MultipleChoice
      def initialize(name, options = {}, &block)
        @include_uk = options.delete(:include_uk)
        @use_legacy_data = options.delete(:use_legacy_data)
        options = country_list
        super(name, options, &block)
      end

      def options
        country_list
      end

      def country_list
        @countries ||= load_countries
      end

      def valid_option?(option)
        options.map{|v| v.slug}.include? (option.to_s)
      end

    private

      def load_countries
        countries = @use_legacy_data ? LegacyCountry.all : WorldLocation.all
        if @include_uk
          countries
        else
          countries.reject {|c| c.slug == 'united-kingdom' }
        end
      end
    end
  end
end
