module SmartAnswer
  module Question
    class CountrySelect < Base
      def initialize(name, options = {}, &block)
        @include_uk = options.delete(:include_uk)
        @exclude_holysee_britishantarticterritory = options.delete(:exclude_holysee_britishantarticterritory)
        @use_legacy_data = options.delete(:use_legacy_data)
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

      def parse_input(raw_input)
        raise SmartAnswer::InvalidResponse, "Illegal option #{raw_input} for #{name}", caller unless valid_option?(raw_input)
        super
      end

    private

      def load_countries
        countries = @use_legacy_data ? LegacyCountry.all : WorldLocation.all
        if @exclude_holysee_britishantarticterritory
          countries.reject {|c| %w(british-antarctic-territory holy-see).include?(c.slug)}
        elsif @include_uk
          countries
        else
          countries.reject {|c| c.slug == 'united-kingdom' }
        end
      end
    end
  end
end
