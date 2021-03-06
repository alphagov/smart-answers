module SmartAnswer
  module Question
    class CountrySelect < Base
      PRESENTER_CLASS = CountrySelectQuestionPresenter

      def initialize(flow, name, options = {}, &block)
        @exclude_countries = options.delete(:exclude_countries)
        @include_uk = options.delete(:include_uk)
        @additional_countries = options.delete(:additional_countries)
        super(flow, name, &block)
      end

      def options
        country_list
      end

      def country_list
        @country_list ||= load_countries
      end

      def valid_option?(option)
        options.map(&:slug).include?(option.to_s)
      end

      def parse_input(raw_input)
        raise SmartAnswer::InvalidResponse, "Illegal option #{raw_input} for #{name}", caller unless valid_option?(raw_input)

        super
      end

    private

      def load_countries
        countries = WorldLocation.all
        unless @include_uk
          countries = countries.reject { |c| c.slug == "united-kingdom" }
        end
        if @exclude_countries
          countries = countries.reject { |c| @exclude_countries.include?(c.slug) }
        end
        if @additional_countries
          countries = (countries + @additional_countries).sort { |a, b| a.name.sub(/^The /i, "") <=> b.name }
        end
        countries
      end
    end
  end
end
